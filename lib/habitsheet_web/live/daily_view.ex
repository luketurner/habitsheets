defmodule HabitsheetWeb.Live.DailyView do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Habits

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:date_range, Date.range(socket.assigns.date, socket.assigns.date))
     |> assign_habits()
     |> assign_entries()}
  end

  @impl true
  def handle_event("toggle_entry", %{"id" => habit_id}, socket) do
    habit = get_habit_from_socket(socket, habit_id)
    entry = socket.assigns.entry_map[String.to_integer(habit_id)]

    additional_data = if(entry, do: :delete, else: [])

    with {:ok, _entry} <-
           Habits.update_habit_entry_for_date_as(
             socket.assigns.current_user,
             habit,
             socket.assigns.date,
             additional_data
           ) do
      {:noreply,
       socket
       |> assign_entries()}
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

  def assign_entries(%{assigns: %{current_user: current_user, date_range: date_range}} = socket) do
    with {:ok, entries} <-
           Habits.list_entries_for_user_as(current_user, current_user, date_range) do
      socket
      |> assign(:entries, entries)
      |> assign(
        :entry_map,
        Habits.entry_map(entries)
      )
    end
  end

  defp get_habit_from_socket(socket, habit_id) do
    Enum.find(socket.assigns.habits, &(to_string(&1.id) == habit_id))
  end
end
