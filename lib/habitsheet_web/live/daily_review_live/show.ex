defmodule HabitsheetWeb.DailyReviewLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Reviews
  alias Habitsheet.Repo

  @impl true
  def mount(%{"sheet_id" => _sheet_id, "date" => date_param}, _session, socket) do
    date = Date.from_iso8601!(date_param)
    current_user = socket.assigns.current_user
    sheet = socket.assigns.sheet

    changeset =
      Reviews.review_upsert_changeset(%{
        user_id: current_user.id,
        sheet_id: sheet.id,
        date: date,
        status: :started,
        email_status: :pending,
        email_failure_count: 0
      })

    with(
      {:ok, review} <- Reviews.upsert_review_for_date_as(current_user, changeset),
      {:ok, habits} <- Reviews.get_habits_for_daily_review_as(current_user, review)
    ) do
      review = Repo.preload(review, :email)

      {:ok,
       socket
       |> assign(:date, date)
       |> assign(:review, review)
       |> assign(:habits, habits)}
    else
      _ ->
        {:ok,
         socket
         |> put_flash(:error, "Error loading review")
         |> push_redirect(to: Routes.sheet_show_path(socket, :show, sheet.id))}
    end
  end

  @impl true
  def handle_event("resend_email", _params, socket) do
    review = Repo.preload(socket.assigns.review, :user)

    case Reviews.send_email_for_daily_review_as(socket.assigns.current_user, review) do
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
