defmodule HabitsheetWeb.Live.HabitList do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Habits

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_habits()}
  end

  @impl true
  def handle_event("archive", %{"id" => habit_id}, socket) do
    habit = get_habit_from_socket(socket, habit_id)

    with {:ok, _habit} <- Habits.archive_habit_as(socket.assigns.current_user, habit) do
      {:noreply,
       socket
       |> assign_habits()}
    end
  end

  @impl true
  def handle_event("unarchive", %{"id" => habit_id}, socket) do
    habit = get_habit_from_socket(socket, habit_id)

    with {:ok, _habit} <- Habits.unarchive_habit_as(socket.assigns.current_user, habit) do
      {:noreply,
       socket
       |> assign_habits()}
    end
  end

  @impl true
  def handle_event(
        "sortable_update",
        %{"id" => habit_id, "newIndex" => new_index, "oldIndex" => old_index},
        socket
      ) do
    habit = get_habit_from_socket(socket, habit_id)

    if old_index == habit.display_order do
      with {:ok} <-
             Habits.reorder_habit_as(
               socket.assigns.current_user,
               socket.assigns.current_user,
               habit,
               new_index
             ) do
        {:noreply,
         socket
         |> assign_habits()}
      end
    else
      # Client sort order is desynced from DB
      # TODO - better logging?
      IO.puts("Client sort order is desynced from DB")
      IO.inspect(habit)
      {:noreply, socket |> assign_habits()}
    end
  end

  defp assign_habits(socket) do
    if socket.assigns.live_action == :archived do
      assign_archived_habits(socket)
    else
      assign_active_habits(socket)
    end
  end

  defp assign_active_habits(socket) do
    with {:ok, habits} <-
           Habits.list_habits_for_user_as(
             socket.assigns.current_user,
             socket.assigns.current_user
           ) do
      socket
      |> assign(:habits, habits)
    end
  end

  defp assign_archived_habits(socket) do
    with {:ok, habits} <-
           Habits.list_archived_habits_for_user_as(
             socket.assigns.current_user,
             socket.assigns.current_user
           ) do
      socket
      |> assign(:habits, habits)
    end
  end

  defp get_habit_from_socket(socket, habit_id) do
    Enum.find(socket.assigns.habits, &(to_string(&1.id) == habit_id))
  end
end
