defmodule Habitsheet.Admin.AdminEmailSender do
  use Quantum, otp_app: :habitsheet

  import Swoosh.Email

  alias Habitsheet.Repo
  alias Habitsheet.Mailer
  alias HabitsheetWeb.Router.Helpers, as: Routes
  alias HabitsheetWeb.Endpoint

  defp admin_email, do: Application.get_env(:habitsheet, :admin_email_address)
  defp outgoing_email, do: Application.get_env(:habitsheet, :outgoing_email_address)

  defp deliver(subject, body) do
    recipient = admin_email()
    if is_nil(recipient) do
      {:ok, nil}
    else
      email =
        new()
        |> to(recipient)
        |> from({"HabitSheets", outgoing_email()})
        |> subject(subject)
        |> text_body(body)

      with {:ok, _metadata} <- Mailer.deliver(email) do
        {:ok, email}
      end
    end
  end

  def digest_task() do

    today = Date.utc_today()
    user_count = Repo.aggregate(Habitsheet.Users.User, :count)
    user_token_count = Repo.aggregate(Habitsheet.Users.UserToken, :count)
    sheet_count = Repo.aggregate(Habitsheet.Sheets.Sheet, :count)
    habit_count = Repo.aggregate(Habitsheet.Sheets.Habit, :count)
    habit_entry_count = Repo.aggregate(Habitsheet.Sheets.HabitEntry, :count)
    daily_review_count = Repo.aggregate(Habitsheet.Reviews.DailyReview, :count)
    daily_review_email_count = Repo.aggregate(Habitsheet.Reviews.DailyReviewEmail, :count)
    home_url = Routes.home_url(Endpoint, :index)

    subject = "Digest #{today} - #{user_count} users, #{sheet_count} sheets, #{daily_review_email_count} review emails"

    body = """
    HabitSheets Admin Digest for #{today}
    =======================================

    Website link: #{home_url}

    Table counts
    ------------

    User: #{user_count}
    UserToken: #{user_token_count}
    Sheet: #{sheet_count}
    Habit: #{habit_count}
    HabitEntry: #{habit_entry_count}
    DailyReview: #{daily_review_count}
    DailyReviewEmail: #{daily_review_email_count}
    """

    deliver(subject, body)
  end
end
