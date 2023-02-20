defmodule Habitsheet.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
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

  def get_or_create_daily_review_by_date(user_id, sheet_id, date) do
    Repo.insert(%DailyReview{
      user_id: user_id,
      sheet_id: sheet_id,
      date: date,
      status: :started,
      email_status: :pending,
      email_failure_count: 0,
    },
    on_conflict: {:replace, [:updated_at]},
    conflict_target: [:user_id, :sheet_id, :date],
    returning: true)
  end

  @doc """
  Returns the list of daily_review.

  ## Examples

      iex> list_daily_review()
      [%DailyReview{}, ...]

  """
  def list_daily_review(user_id, sheet_id) do
    Repo.all(from r in DailyReview, select: r, where: r.user_id == ^user_id and r.sheet_id == ^sheet_id)
  end

  @doc """
  Gets a single daily_review.

  Raises `Ecto.NoResultsError` if the Daily review does not exist.

  ## Examples

      iex> get_daily_review!(123)
      %DailyReview{}

      iex> get_daily_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_daily_review_by_date(user_id, sheet_id, date), do: Repo.get_by(DailyReview, [user_id: user_id, sheet_id: sheet_id, date: date])
  def get_daily_review(user_id, sheet_id, review_id), do: Repo.get_by(DailyReview, [user_id: user_id, sheet_id: sheet_id, id: review_id])
  def get_daily_review!(user_id, sheet_id, review_id), do: Repo.get_by!(DailyReview, [user_id: user_id, sheet_id: sheet_id, id: review_id])

  @doc """
  Creates a daily_review.

  ## Examples

      iex> create_daily_review(%{field: value})
      {:ok, %DailyReview{}}

      iex> create_daily_review(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_daily_review(user_id, sheet_id, attrs \\ %{}) do
    attrs = attrs
      |> Map.put(:user_id, user_id)
      |> Map.put(:sheet_id, sheet_id)

    %DailyReview{}
    |> DailyReview.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a daily_review.

  ## Examples

      iex> update_daily_review(daily_review, %{field: new_value})
      {:ok, %DailyReview{}}

      iex> update_daily_review(daily_review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_daily_review(user_id, sheet_id, %DailyReview{} = daily_review, attrs) do
    get_daily_review!(user_id, sheet_id, daily_review.id)

    # don't allow overwriting owner or sheet
    Map.drop(attrs, [:user_id, :sheet_id])

    daily_review
    |> DailyReview.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a daily_review.

  ## Examples

      iex> delete_daily_review(daily_review)
      {:ok, %DailyReview{}}

      iex> delete_daily_review(daily_review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_daily_review!(user_id, sheet_id, %DailyReview{} = daily_review) do
    get_daily_review!(user_id, sheet_id, daily_review.id)

    Repo.delete(daily_review)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking daily_review changes.

  ## Examples

      iex> change_daily_review(daily_review)
      %Ecto.Changeset{data: %DailyReview{}}

  """
  def change_daily_review(%DailyReview{} = daily_review, attrs \\ %{}) do
    DailyReview.changeset(daily_review, attrs)
  end

  def fill_daily_reviews(date_range) do
    all_users = Users.list_users()

    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    reviews = Enum.flat_map(all_users, fn user ->
      Enum.flat_map(Sheets.list_sheets(user.id), fn sheet ->
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
    {_count, _new_review_ids} = Repo.insert_all(
      DailyReview,
      reviews,
      on_conflict: :nothing, # {:replace, [:updated_at]},
      conflict_target: [:user_id, :sheet_id, :date],
      returning: [:id]
    )

    {:ok, []}
  end

  def send_emails_for_daily_reviews_with_pending_attempts() do
    Enum.map(get_daily_reviews_with_pending_attempts(), fn {review, email, daily_review_email_enabled, daily_review_email_time } ->
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

  def get_daily_reviews_with_pending_attempts() do
    max_email_failure_count = Application.get_env(:habitsheet, :review_email_max_failure_count)
    Repo.all(
      from review in DailyReview,
      join: user in User, on: review.user_id == user.id,
      join: sheet in Sheet, on: review.sheet_id == sheet.id,
      select: {review, user.email, sheet.daily_review_email_enabled, sheet.daily_review_email_time},
      where:
        review.email_status in [:pending, :failed] and
        review.email_failure_count < ^max_email_failure_count
    )
  end

  def get_habits_for_daily_review(review) do
    Repo.all(
      from habit in Habit,
      left_join: entry in HabitEntry, on: entry.habit_id == habit.id,
      select: %{habit | entry: entry},
      where: habit.sheet_id == ^review.sheet_id
         and habit.user_id == ^review.user_id
         and (is_nil(entry.id) or entry.date == ^review.date)
         # habit needs to either: not be archived, or have an entry
         and (is_nil(habit.archived_at) or not is_nil(entry.id))
    )
  end

  # @doc """
  # Returns the list of daily_review_emails.

  # ## Examples

  #     iex> list_daily_review_emails()
  #     [%DailyReviewEmail{}, ...]

  # """
  # def list_daily_review_emails do
  #   Repo.all(DailyReviewEmail)
  # end

  # @doc """
  # Gets a single daily_review_email.

  # Raises `Ecto.NoResultsError` if the Daily review email does not exist.

  # ## Examples

  #     iex> get_daily_review_email!(123)
  #     %DailyReviewEmail{}

  #     iex> get_daily_review_email!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_daily_review_email!(id), do: Repo.get!(DailyReviewEmail, id)

  # @doc """
  # Creates a daily_review_email.

  # ## Examples

  #     iex> create_daily_review_email(%{field: value})
  #     {:ok, %DailyReviewEmail{}}

  #     iex> create_daily_review_email(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  def create_daily_review_email(attrs \\ %{}) do
    %DailyReviewEmail{}
    |> DailyReviewEmail.changeset(attrs)
    |> Repo.insert()
  end

  # @doc """
  # Updates a daily_review_email.

  # ## Examples

  #     iex> update_daily_review_email(daily_review_email, %{field: new_value})
  #     {:ok, %DailyReviewEmail{}}

  #     iex> update_daily_review_email(daily_review_email, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_daily_review_email(%DailyReviewEmail{} = daily_review_email, attrs) do
  #   daily_review_email
  #   |> DailyReviewEmail.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a daily_review_email.

  # ## Examples

  #     iex> delete_daily_review_email(daily_review_email)
  #     {:ok, %DailyReviewEmail{}}

  #     iex> delete_daily_review_email(daily_review_email)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_daily_review_email(%DailyReviewEmail{} = daily_review_email) do
  #   Repo.delete(daily_review_email)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking daily_review_email changes.

  # ## Examples

  #     iex> change_daily_review_email(daily_review_email)
  #     %Ecto.Changeset{data: %DailyReviewEmail{}}

  # """
  # def change_daily_review_email(%DailyReviewEmail{} = daily_review_email, attrs \\ %{}) do
  #   DailyReviewEmail.changeset(daily_review_email, attrs)
  # end
end
