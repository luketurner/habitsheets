defmodule HabitsheetWeb.DailyReviewLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Reviews
  alias Habitsheet.Reviews.DailyReview
  alias Habitsheet.Repo

  @default_time_remaining Time.from_seconds_after_midnight(300)

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
       |> assign(:habits, habits)
       |> assign(:time_remaining, @default_time_remaining)
       |> assign(:default_time_remaining, @default_time_remaining)
       |> assign(:timer, nil)}
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
  def handle_event("finish_review", _params, socket) do
    changeset =
      Reviews.review_update_changeset(socket.assigns.review, %{
        status: :finished
      })

    with {:ok, review} <- Reviews.update_review_as(socket.assigns.current_user, changeset) do
      {:noreply,
       socket
       |> assign(:review, review)
       |> put_flash(:info, "Review finished")
       |> push_navigate(to: Routes.sheet_show_path(socket, :show, socket.assigns.sheet.id))}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Error finishing review")}
    end
  end

  @impl true
  def handle_event("toggle_timer", _params, %{assigns: %{timer: timer}} = socket)
      when not is_nil(timer) do
    {:noreply, socket |> clear_timer()}
  end

  @impl true
  def handle_event("toggle_timer", _params, socket) do
    {:noreply, socket |> assign_timer()}
  end

  @impl true
  def handle_event("restart_timer", _params, socket) do
    {:noreply, socket |> assign(:time_remaining, @default_time_remaining) |> assign_timer()}
  end

  @impl true
  def handle_info(:tick_timer, socket) do
    new_time = Time.add(socket.assigns.time_remaining, -1)
    # prevent time from rolling over
    new_time = if new_time > socket.assigns.time_remaining, do: ~T[00:00:00], else: new_time
    {:noreply, socket |> assign(:time_remaining, new_time)}
  end

  defp assign_timer(socket) do
    socket = socket |> clear_timer()

    with {:ok, tref} <- :timer.send_interval(1000, :tick_timer) do
      socket |> assign(:timer, tref)
    else
      # TODO
      _ -> socket
    end
  end

  defp clear_timer(socket) do
    tref = socket.assigns[:timer]
    if tref, do: :timer.cancel(tref)
    socket |> assign(:timer, nil)
  end

  defp elapsed_time_percent(total, remaining) do
    {total_secs, _} = Time.to_seconds_after_midnight(total)
    {remaining_secs, _} = Time.to_seconds_after_midnight(remaining)
    (total_secs - remaining_secs) * (100 / total_secs)
  end
end
