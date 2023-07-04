defmodule HabitsheetWeb.Live.DailyView do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheet
  alias Habitsheet.Agendas.Agenda

  @impl true
  def mount(%{"date" => date_param} = _params, _session, socket) do
    {:ok,
     socket
     |> assign(:date_param, date_param)
     |> assign_sheet()}
  end

  @impl true
  def handle_event(
        "toggle_task_completed",
        %{"id" => task_id},
        %{assigns: %{sheet: sheet, date: date}} = socket
      ) do
    task = get_task_from_socket(socket, task_id)

    with {:ok, sheet} <- Sheet.toggle_task_completed(sheet, task, date) do
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

  @impl true
  def handle_event("agenda_generate", _params, %{assigns: %{sheet: sheet, date: date}} = socket) do
    {:ok, sheet} = Sheet.build_agenda(sheet, date)
    {:noreply, socket |> assign_sheet(sheet)}
  end

  @impl true
  def handle_event("agenda_add_tasks", _params, %{assigns: %{sheet: sheet, date: date}} = socket) do
    {:ok, sheet} = Sheet.agenda_add_tasks(sheet, date, %{
      num_important_tasks: 1,
      num_other_tasks: 1
    })
    {:noreply, socket |> assign_sheet(sheet)}
  end

  @impl true
  def handle_event("agenda_refresh_tasks", _params, %{assigns: %{sheet: sheet, date: date}} = socket) do
    {:ok, sheet} = Sheet.agenda_refresh_tasks(sheet, date)
    {:noreply, socket |> assign_sheet(sheet)}
  end

  defp assign_sheet(%{assigns: %{date: date}} = socket, %Sheet{} = sheet) do
    socket
    |> assign(:sheet, sheet)
    |> assign(:habits, Sheet.get_habits_for_date(sheet, date))
    |> assign(:review, Sheet.get_review(sheet, date) || %{})
    |> assign(:agenda, Sheet.get_agenda_for_date(sheet, date))
  end

  defp assign_sheet(%{assigns: %{current_user: current_user, date: date}} = socket) do
    {:ok, sheet} = Sheet.new(current_user, date)

    assign_sheet(socket, sheet)
  end

  defp get_habit_from_socket(socket, habit_id) do
    Sheet.get_habit(socket.assigns.sheet, habit_id)
  end

  defp get_task_from_socket(%{assigns: %{sheet: sheet, date: date}}, task_id) do
    agenda = Sheet.get_agenda_for_date(sheet, date)
    Agenda.find_task(agenda, task_id)
  end

  defp date_param_add(date, days) do
    date |> Date.add(days) |> Date.to_iso8601()
  end
end
