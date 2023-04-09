defmodule HabitsheetWeb.Live.DailyReview do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Habits
  alias Habitsheet.Reviews
  alias Habitsheet.Reviews.DailyReview

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
     |> assign_review()}
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
end
