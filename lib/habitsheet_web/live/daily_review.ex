defmodule HabitsheetWeb.Live.DailyReview do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Habits
  alias Habitsheet.Reviews
  alias Habitsheet.Reviews.DailyReview

  @default_time_remaining Time.from_seconds_after_midnight(300)

  @impl true
  def mount(%{"date" => date_param} = _params, _session, socket) do
    socket = socket |> assign_review()

    {:ok, review} =
      if socket.assigns.review.status == :not_started do
        changeset = DailyReview.update_changeset(socket.assigns.review, %{status: :started})
        Reviews.update_review_as(socket.assigns.current_user, changeset)
      else
        {:ok, socket.assigns.review}
      end

    socket = socket |> assign(:review, review)

    {:ok,
     socket
     |> assign(:date_param, date_param)
     |> assign_habits()
     |> assign_entries()
     |> assign_review()
     |> assign(:time_remaining, @default_time_remaining)
     |> assign(:default_time_remaining, @default_time_remaining)
     |> assign(:timer, nil)}
  end

  @impl true
  def handle_event("finish", _params, socket) do
    changeset = DailyReview.update_changeset(socket.assigns.review, %{status: :finished})

    with {:ok, _review} <-
           Reviews.update_review_as(socket.assigns.current_user, changeset) do
      {:noreply,
       socket
       |> put_flash(:info, "Review finished")
       |> push_redirect(to: Routes.daily_view_path(socket, :index, socket.assigns.date_param))}
    else
      _ -> {:noreply, socket}
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
    {:noreply, socket |> assign(:time_remaining, @default_time_remaining) |> clear_timer()}
  end

  @impl true
  def handle_info(:tick_timer, socket) do
    # Don't decrement if the timer has already been removed.
    # This prevents an extra second from ticking off after the user clicks pause.
    new_time =
      if socket.assigns.timer,
        do: Time.add(socket.assigns.time_remaining, -1),
        else: socket.assigns.time_remaining

    # prevent time from rolling over when it goes below midnight
    new_time = if new_time > socket.assigns.time_remaining, do: ~T[00:00:00], else: new_time
    {:noreply, socket |> assign(:time_remaining, new_time)}
  end

  def assign_habits(socket) do
    with {:ok, habits} <-
           Habits.list_habits_for_user_as(
             socket.assigns.current_user,
             socket.assigns.current_user
           ) do
      socket
      |> assign(:habits, habits)
    end
  end

  def assign_entries(%{assigns: %{current_user: current_user, date: date}} = socket) do
    with {:ok, entries} <-
           Habits.list_entries_for_user_as(current_user, current_user, date) do
      socket
      |> assign(:entries, entries)
      |> assign(
        :entry_map,
        Habits.entry_map(entries)
      )
    end
  end

  defp assign_review(%{assigns: %{current_user: current_user, date: date}} = socket) do
    changeset =
      Reviews.review_upsert_changeset(%DailyReview{}, %{
        date: date,
        user_id: current_user.id
      })

    # TODO I don't want to actually create a review until the user does some modification
    with {:ok, review} <- Reviews.upsert_review_for_date_as(current_user, changeset) do
      socket |> assign(:review, review)
    else
      _ -> socket
    end
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
