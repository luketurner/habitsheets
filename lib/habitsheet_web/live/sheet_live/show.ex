defmodule HabitsheetWeb.SheetLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Habit

  @impl true
  def mount(%{ "id" => id }, _session, socket) do
    date_range = Sheets.get_week_range(Date.utc_today())
    {:ok, socket
      |> assign(:id, id)
      |> assign(:sheet, Sheets.get_sheet!(id))
      |> assign(:habits, list_habits(id))
      |> assign(:date_range, date_range)
      |> assign(:habit_entries, all_habit_entries(id, date_range))
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_habit, %{"habit_id" => habit_id}) do
    socket
    |> assign(:page_title, "Edit habit...")
    |> assign(:habit, Sheets.get_habit!(habit_id))
  end

  defp apply_action(socket, :new_habit, _params) do
    socket
    |> assign(:page_title, "New habit...")
    |> assign(:habit, %Habit{})
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Sheet")
    |> assign(:habit, nil)
  end

  @impl true
  def handle_event("delete", %{"habit_id" => habit_id}, socket) do
    habit = Sheets.get_habit!(habit_id)
    {:ok, _} = Sheets.delete_habit(habit)

    {:noreply, assign(socket, :habits, list_habits(socket.assigns.id))}
  end

  @impl true
  def handle_event("toggle_day", %{"value" => _value, "date" => date, "habit" => habit_id}, socket) do
    Sheets.update_habit_entry_for_date(habit_id, date, 1)
    {:noreply, assign(socket, :habit_entries, all_habit_entries(socket.assigns.id, socket.assigns.date_range))}
  end

  @impl true
  def handle_event("toggle_day", %{"date" => date, "habit" => habit_id}, socket) do
    Sheets.update_habit_entry_for_date(habit_id, date, 0)
    {:noreply, assign(socket, :habit_entries, all_habit_entries(socket.assigns.id, socket.assigns.date_range))}
  end

  @impl true
  def handle_event("prev_week", _params, socket) do
    prev_week = Sheets.get_week_range(Date.add(socket.assigns.date_range.first, -1))
    {:noreply, socket
      |> assign(:date_range, prev_week)
      |> assign(:habit_entries, all_habit_entries(socket.assigns.id, prev_week))
    }
  end

  @impl true
  def handle_event("next_week", _params, socket) do
    next_week = Sheets.get_week_range(Date.add(socket.assigns.date_range.last, 1))
    {:noreply, socket
      |> assign(:date_range, next_week)
      |> assign(:habit_entries, all_habit_entries(socket.assigns.id, next_week))
    }
  end

  defp list_habits(sheet_id) do
    Sheets.list_habits(sheet_id)
  end

  defp all_habit_entries(sheet_id, days) do
    Map.new(list_habits(sheet_id), fn habit -> {
      habit.id,
      entries_for_habit(habit.id, days)
    } end)
  end

  defp entries_for_habit(habit_id, days) do
    Sheets.get_habit_entry_value_map(habit_id, days)
  end

  defp get_habit_entry_for_date(habit_entries, habit_id, date) do
    habit_entries
    |> Map.get(habit_id, Map.new())
    |> Map.get(date, 0)
  end

  defp short_date(date) do
    "#{date.month}/#{date.day}"
  end

  defp day_of_week(date) do
    case Date.day_of_week(date) do
      1 -> "M"
      2 -> "T"
      3 -> "W"
      4 -> "T"
      5 -> "F"
      6 -> "S"
      7 -> "S"
    end
  end

end