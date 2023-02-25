defmodule HabitsheetWeb.DailyReviewLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Reviews.ReviewEmailSender
  alias Habitsheet.Reviews
  alias Habitsheet.Repo

  @impl true
  def mount(%{"sheet_id" => _sheet_id, "date" => date_param}, _session, socket) do
    date = Date.from_iso8601!(date_param)
    user_id = socket.assigns.current_user.id
    sheet_id = socket.assigns.sheet.id

    with {:ok, review} = Reviews.get_or_create_daily_review_by_date(user_id, sheet_id, date) do
      habits = Reviews.get_habits_for_daily_review(review)
      review = Repo.preload(review, :email)

      {:ok,
       socket
       |> assign(:date, date)
       |> assign(:review, review)
       |> assign(:habits, habits)}
    end
  end

  @impl true
  def handle_event("resend_email", _params, socket) do
    review = Repo.preload(socket.assigns.review, :user)

    case ReviewEmailSender.send_email_for_daily_review(review, review.user.email, :user) do
      {:ok, _email} ->
        {:noreply,
         socket
         |> put_flash(:info, "Email sent to: #{review.user.email}")
         |> assign(:review, Repo.preload(Repo.reload(review), :email, force: true))}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error sending email")
         |> assign(:review, Repo.preload(Repo.reload(review), :email, force: true))}
    end
  end
end
