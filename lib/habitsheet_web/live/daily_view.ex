defmodule HabitsheetWeb.Live.DailyView do
  use HabitsheetWeb, :live_view

  alias Ecto.Changeset

  alias Habitsheet.Habits
  alias Habitsheet.Habits.HabitEntry
  alias Habitsheet.Habits.AdditionalData

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

  @impl true
  def handle_event(
        "update_entry",
        %{
          "habit_entry" => %{"habit_id" => habit_id_param, "date" => date_param} = entry_params
        },
        socket
      ) do
    # Massage params
    habit = get_habit_from_socket(socket, habit_id_param)
    date = Date.from_iso8601!(date_param)
    entry_params = Map.put_new(entry_params, "additional_data", [])

    # Validate changes
    changeset = HabitEntry.create_changeset(%HabitEntry{}, entry_params)
    entry = Changeset.apply_action!(changeset, :validate)

    # Create or update the entry
    case Habits.update_habit_entry_for_date_as(
           socket.assigns.current_user,
           habit,
           date,
           entry.additional_data
         ) do
      {:ok, _entry} ->
        {:noreply, socket |> assign_entries()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
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

  defp get_habit_from_socket(socket, habit_id) when is_integer(habit_id) do
    Enum.find(socket.assigns.habits, &(&1.id == habit_id))
  end

  defp get_habit_from_socket(socket, habit_id) when is_binary(habit_id) do
    get_habit_from_socket(socket, String.to_integer(habit_id))
  end

  defp changeset_for_entry(entry_map, habit, date) do
    if entry = entry_map[habit.id] do
      HabitEntry.changeset(entry, %{
        additional_data: build_additional_data(entry.additional_data, habit)
      })
    else
      HabitEntry.create_changeset(%HabitEntry{}, %{
        habit_id: habit.id,
        date: date,
        additional_data: build_additional_data([], habit)
      })
    end
  end

  defp build_additional_data(current_data, habit) do
    current_data
    |> AdditionalData.zip_spec(habit.additional_data_spec)
    |> Enum.map(fn {data, _spec} -> Map.take(data, AdditionalData.__schema__(:fields)) end)
  end
end
