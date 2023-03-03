defmodule Habitsheet.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Habitsheet.Repo

  alias Habitsheet.Reviews.DailyReviewEmail
  alias Habitsheet.Reviews.DailyReview
  alias Habitsheet.Reviews.ReviewEmailSender

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Sheet
  alias Habitsheet.Sheets.Habit
  alias Habitsheet.Sheets.HabitEntry

  alias Habitsheet.Users
  alias Habitsheet.Users.User

  alias __MODULE__

  @behaviour Bodyguard.Policy

  def authorize(:get_review, %User{id: user_id}, %DailyReview{user_id: user_id}), do: :ok
  def authorize(:update_review, %User{id: user_id}, %DailyReview{user_id: user_id}), do: :ok

  def authorize(:upsert_review, %User{id: user_id}, %Changeset{changes: %{user_id: user_id}}),
    do: :ok

  def authorize(:receive_review_emails, %User{id: user_id}, %DailyReview{user_id: user_id}),
    do: :ok

  def authorize(:list_reviews_for_sheet, %User{id: user_id}, %Sheet{user_id: user_id}), do: :ok

  def authorize(_, _, _), do: :error

  def list_review_metadata_for_dates_as(%User{} = current_user, %Sheet{} = sheet, date_range) do
    with(:ok <- Bodyguard.permit(Reviews, :list_reviews_for_sheet, current_user, sheet)) do
      {:ok,
       Repo.all(
         from(review in DailyReview,
           select: [:id, :date, :status, :user_id, :sheet_id],
           where:
             review.sheet_id == ^sheet.id and review.date >= ^date_range.first and
               review.date <= ^date_range.last
         )
         |> Bodyguard.scope(current_user)
       )}
    end
  end

  def upsert_review_for_date(%Changeset{} = changeset) do
    Repo.insert(
      changeset,
      on_conflict: {:replace, [:updated_at]},
      conflict_target: [:user_id, :sheet_id, :date],
      returning: true
    )
  end

  def upsert_review_for_date_as(%User{} = current_user, %Changeset{} = changeset) do
    with(
      :ok <- Bodyguard.permit(Reviews, :upsert_review, current_user, changeset),
      {:ok, review} <- upsert_review_for_date(changeset),
      :ok <- Bodyguard.permit(Reviews, :get_review, current_user, review)
    ) do
      {:ok, review}
    end
  end

  def review_upsert_changeset(%DailyReview{} = review, attrs \\ %{}) do
    DailyReview.upsert_changeset(review, attrs)
  end

  def review_update_changeset(%DailyReview{} = review, attrs \\ %{}) do
    DailyReview.update_changeset(review, attrs)
  end

  def update_review(%Changeset{data: %DailyReview{}} = changeset) do
    Repo.update(changeset)
  end

  def update_review_as(
        %User{} = current_user,
        %Changeset{data: %DailyReview{} = review} = changeset
      ) do
    with(
      :ok <- Bodyguard.permit(Reviews, :update_review, current_user, review),
      {:ok, review} <- update_review(changeset),
      :ok <- Bodyguard.permit(Reviews, :get_review, current_user, review)
    ) do
      {:ok, review}
    end
  end

  def fill_daily_reviews(date_range) do
    all_users = Users.list_users()

    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    reviews =
      Enum.flat_map(all_users, fn user ->
        # TODO -- should handle errors better
        {:ok, sheets} = Sheets.list_sheets_for_user(user)

        Enum.flat_map(sheets, fn sheet ->
          Enum.map(date_range, fn date ->
            %{
              user_id: sheet.user_id,
              sheet_id: sheet.id,
              date: date,
              email_status: :pending,
              email_failure_count: 0,
              email_attempt_count: 0,
              status: :not_started,
              inserted_at: now,
              updated_at: now
            }
          end)
        end)
      end)

    # TODO -- I wonder if there is a better way to do this...
    {_count, _new_review_ids} =
      Repo.insert_all(
        DailyReview,
        reviews,
        # {:replace, [:updated_at]},
        on_conflict: :nothing,
        conflict_target: [:user_id, :sheet_id, :date],
        returning: [:id]
      )

    {:ok, []}
  end

  def send_emails_for_daily_reviews_with_pending_attempts() do
    Enum.map(get_daily_reviews_with_pending_attempts(), fn {review, email,
                                                            daily_review_email_enabled,
                                                            daily_review_email_time} ->
      if !daily_review_email_enabled or is_nil(email) do
        Repo.update(DailyReview.changeset(review, %{email_status: :skipped}))
      else
        # TODO
        review = Repo.preload(review, :user)
        now = DateTime.to_time(DateTime.now!(review.user.timezone))

        if Time.compare(daily_review_email_time, Time.add(now, -30, :minute)) == :lt do
          ReviewEmailSender.send_email_for_daily_review(review, email, :fill_review)
        end
      end
    end)
  end

  def send_email_for_daily_review_as(%User{} = current_user, %DailyReview{} = review) do
    with :ok <- Bodyguard.permit(Reviews, :receive_review_emails, current_user, review) do
      ReviewEmailSender.send_email_for_daily_review(review, current_user.email, :user)
    end
  end

  def get_daily_reviews_with_pending_attempts() do
    max_email_failure_count = Application.get_env(:habitsheet, :review_email_max_failure_count)

    Repo.all(
      from review in DailyReview,
        join: user in User,
        on: review.user_id == user.id,
        join: sheet in Sheet,
        on: review.sheet_id == sheet.id,
        select:
          {review, user.email, sheet.daily_review_email_enabled, sheet.daily_review_email_time},
        where:
          review.email_status in [:pending, :failed] and
            review.email_failure_count < ^max_email_failure_count
    )
  end

  def get_habits_for_daily_review(%DailyReview{} = review) do
    {:ok,
     Repo.all(
       from habit in Habit,
         left_join: entry in HabitEntry,
         on: entry.habit_id == habit.id,
         select: %{habit | entry: entry},
         # habit needs to either: not be archived, or have an entry
         where:
           habit.sheet_id == ^review.sheet_id and
             habit.user_id == ^review.user_id and
             (is_nil(entry.id) or entry.date == ^review.date) and
             (is_nil(habit.archived_at) or not is_nil(entry.id))
     )}
  end

  def get_habits_for_daily_review_as(%User{} = current_user, %DailyReview{} = review) do
    # TODO reduce code duplication here
    {:ok,
     Repo.all(
       from(
         habit in Habit,
         left_join: entry in HabitEntry,
         on: entry.habit_id == habit.id,
         select: %{habit | entry: entry},
         # habit needs to either: not be archived, or have an entry
         where:
           habit.sheet_id == ^review.sheet_id and
             habit.user_id == ^review.user_id and
             (is_nil(entry.id) or entry.date == ^review.date) and
             (is_nil(habit.archived_at) or not is_nil(entry.id))
       )
       |> Bodyguard.scope(current_user)
     )}
  end

  def create_daily_review_email(attrs \\ %{}) do
    %DailyReviewEmail{}
    |> DailyReviewEmail.changeset(attrs)
    |> Repo.insert()
  end
end
