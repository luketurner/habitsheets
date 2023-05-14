defmodule HabitsheetWeb.Live.DailyView do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheet

  @impl true
  def mount(%{"date" => date_param} = _params, _session, socket) do
    {:ok,
     socket
     |> assign(:date_param, date_param)
     |> assign_sheet()}
  end

  @impl true
  def handle_event(
        "toggle_entry",
        %{"id" => habit_id},
        %{assigns: %{sheet: sheet, date: date}} = socket
      ) do
    habit = get_habit_from_socket(socket, habit_id)

    with {:ok, sheet} <- Sheet.toggle_entry(sheet, habit, date) do
      {:noreply, assign(socket, :sheet, sheet)}
    end
  end

  @impl true
  def handle_event(
        "update_entry",
        %{"habit_entry" => %{"habit_id" => habit_id, "date" => date} = entry_params},
        socket
      ) do
    # Massage params
    habit = get_habit_from_socket(socket, habit_id)
    date = Date.from_iso8601!(date)
    entry_params = Map.put_new(entry_params, "additional_data", [])

    # Create or update the entry
    case Sheet.update_entry(socket.assigns.sheet, habit, date, entry_params) do
      {:ok, sheet} ->
        {:noreply, assign(socket, :sheet, sheet)}

      # TODO
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_sheet(%{assigns: %{current_user: current_user, date: date}} = socket) do
    {:ok, sheet} = Sheet.new(current_user, date)

    socket
    |> assign(:sheet, sheet)
    |> assign(:habits, Sheet.get_habits_for_date(sheet, date))
    |> assign(:review, Sheet.get_review(sheet, date) || %{})
  end

  defp get_habit_from_socket(socket, habit_id) when is_integer(habit_id) do
    Enum.find(socket.assigns.sheet.habits, &(&1.id == habit_id))
  end

  defp get_habit_from_socket(socket, habit_id) when is_binary(habit_id) do
    get_habit_from_socket(socket, String.to_integer(habit_id))
  end

  defp date_param_add(date, days) do
    date |> Date.add(days) |> Date.to_iso8601()
  end
end
