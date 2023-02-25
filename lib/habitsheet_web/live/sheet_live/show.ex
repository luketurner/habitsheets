defmodule HabitsheetWeb.SheetLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Habit

  @impl true
  def mount(_params, _session, socket) do
    full_week_view? = breakpoint?(socket, :md)
    today = DateTime.to_date(DateTime.now!(socket.assigns.timezone))
    date_range = if full_week_view? do
      Date.range(
        Date.beginning_of_week(today),
        Date.end_of_week(today)
      )
    else
      Date.range(today, today)
    end
    {:ok, socket
      |> assign(:date_range, date_range)
      |> assign_habits()
      |> assign_habit_entries()
      |> assign(:subtitle, socket.assigns.sheet.title || "Unnamed Sheet")
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp find_habit(socket, habit_id), do: Enum.find(socket.assigns.habits, fn habit -> to_string(habit.id) == habit_id end)

  defp apply_action(socket, :edit_habit, %{"habit_id" => habit_id}) do
    habit = find_habit(socket, habit_id)
    socket
    |> assign(:page_title, "Edit habit")
    |> assign(:habit, habit)
  end

  defp apply_action(socket, :new_habit, _params) do
    socket
    |> assign(:page_title, "New habit")
    |> assign(:habit, %Habit{})
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Sheet")
    |> assign(:habit, nil)
  end

  defp apply_action(socket, :share, _params) do
    socket
    |> assign(:page_title, "Share Sheet")
    |> assign(:habit, nil)
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Edit Sheet")
    |> assign(:habit, nil)
  end

  @impl true
  def handle_event("toggle_day", %{"value" => _value, "date" => date, "habit" => habit_id}, socket) do
    habit = find_habit(socket, habit_id)
    case Sheets.update_habit_entry_for_date_as(socket.assigns.current_user, habit, date, 1) do
      # TODO -- error handling
      {:ok, _} -> {:noreply, assign_habit_entries(socket)}
      {:error, _} -> {:noreply, assign_habit_entries(socket)}
    end

  end

  @impl true
  def handle_event("toggle_day", %{"date" => date, "habit" => habit_id}, socket) do
    habit = find_habit(socket, habit_id)
    Sheets.update_habit_entry_for_date_as(socket.assigns.current_user, habit, date, 0)
    {:noreply, assign_habit_entries(socket)}
  end

  @impl true
  def handle_event("prev_week", _params, socket) do
    old_range = socket.assigns.date_range
    new_range = Date.range(
      Date.add(old_range.first, -Enum.count(old_range)),
      Date.add(old_range.first, -1)
    )
    {:noreply, socket
      |> assign(:date_range, new_range)
      |> assign_habit_entries()}
  end

  @impl true
  def handle_event("next_week", _params, socket) do
    old_range = socket.assigns.date_range
    new_range = Date.range(
      Date.add(old_range.last, 1),
      Date.add(old_range.last, Enum.count(old_range))
    )
    {:noreply, socket
      |> assign(:date_range, new_range)
      |> assign_habit_entries()}
  end

  defp assign_habits(%{ assigns: %{current_user: current_user, sheet: sheet} } = socket) do
    case Sheets.list_habits_for_sheet_as(current_user, sheet) do
      {:ok, habits} -> assign(socket, :habits, habits)
      {:error, _} -> assign(socket, :habits, []) # TODO
    end
  end

  defp assign_habit_entries(%{ assigns: %{current_user: current_user, sheet: sheet, date_range: date_range, habits: habits} } = socket) do
    case Sheets.list_habit_entries_for_sheet_as(current_user, sheet, date_range) do
      {:ok, entries} -> assign(socket, :habit_entries, Sheets.habit_entry_map(habits, date_range, entries))
      {:error, _} -> assign(socket, :habit_entries, %{}) # TODO
    end
  end

end
