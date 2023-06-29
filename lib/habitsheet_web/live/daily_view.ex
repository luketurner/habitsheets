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
        "complete_task",
        %{"id" => task_id},
        %{assigns: %{sheet: sheet, date: date}} = socket
      ) do
    task = get_task_from_socket(socket, task_id)

    with {:ok, sheet} <- Sheet.complete_task(sheet, task, date) do
      {:noreply, assign_sheet(socket, sheet)}
    end
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

  defp assign_sheet(%{assigns: %{date: date}} = socket, %Sheet{} = sheet) do
    socket
    |> assign(:sheet, sheet)
    |> assign(:habits, Sheet.get_habits_for_date(sheet, date))
    |> assign(:review, Sheet.get_review(sheet, date) || %{})
    |> assign(:tasks, Sheet.get_tasks_for_date(sheet, date))
  end

  defp assign_sheet(%{assigns: %{current_user: current_user, date: date}} = socket) do
    {:ok, sheet} = Sheet.new(current_user, date)

    assign_sheet(socket, sheet)
  end

  defp get_habit_from_socket(socket, habit_id) when is_integer(habit_id) do
    # TODO -- should use habit_index
    Enum.find(socket.assigns.sheet.habits, &(&1.id == habit_id))
  end

  defp get_habit_from_socket(socket, habit_id) when is_binary(habit_id) do
    get_habit_from_socket(socket, String.to_integer(habit_id))
  end

  defp get_task_from_socket(socket, task_id) when is_integer(task_id) do
    # TODO -- should use task_index
    Enum.find(socket.assigns.sheet.tasks, &(&1.id == task_id))
  end

  defp get_task_from_socket(socket, task_id) when is_binary(task_id) do
    get_task_from_socket(socket, String.to_integer(task_id))
  end

  defp date_param_add(date, days) do
    date |> Date.add(days) |> Date.to_iso8601()
  end
end
