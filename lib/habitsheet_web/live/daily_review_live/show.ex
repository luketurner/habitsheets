defmodule HabitsheetWeb.DailyReviewLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Reviews
  alias Habitsheet.Reviews.DailyReview
  alias Habitsheet.Repo

  @impl true
  def mount(%{"sheet_id" => _sheet_id, "date" => date_param}, _session, socket) do
    date = Date.from_iso8601!(date_param)
    current_user = socket.assigns.current_user
    sheet = socket.assigns.sheet

    changeset =
      Reviews.review_upsert_changeset(%DailyReview{}, %{
        user_id: current_user.id,
        sheet_id: sheet.id,
        date: date,
        status: :not_started,
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
       |> assign(:habits, habits)
       |> assign_new(:time_remaining, fn _ -> 300 end)
       |> assign_timer_for_status(review.status)}
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

  @impl true
  def handle_event("advance", _params, socket) do
    next_status =
      case socket.assigns.review.status do
        :not_started -> :started
        :started -> :finished
        default -> default
      end

    changeset =
      Reviews.review_update_changeset(socket.assigns.review, %{
        status: next_status
      })

    with {:ok, review} <- Reviews.update_review_as(socket.assigns.current_user, changeset) do
      {:noreply, socket |> assign(:review, review) |> assign_timer_for_status(review.status)}
    end
  end

  @impl true
  def handle_info(:tick_timer, socket) do
    {:noreply, socket |> assign(:time_remaining, max(0, socket.assigns.time_remaining - 1))}
  end

  defp assign_timer(socket) do
    socket = socket |> clear_timer()

    with {:ok, tref} <- :timer.send_interval(1000, :tick_timer) do
      socket |> assign(:time_ref, tref)
    else
      # TODO
      _ -> socket
    end
  end

  defp clear_timer(socket) do
    tref = socket.assigns[:time_ref]
    if tref, do: :timer.cancel(tref)
    socket |> assign(:time_ref, nil)
  end

  defp assign_timer_for_status(socket, status) do
    if status == :started do
      assign_timer(socket)
    else
      clear_timer(socket)
    end
  end
end
