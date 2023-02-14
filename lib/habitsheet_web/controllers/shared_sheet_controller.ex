defmodule HabitsheetWeb.SharedSheetController do
  use HabitsheetWeb, :controller

  alias Habitsheet.Sheets

  def show(conn, %{"id" => share_id}) do
    sheet = Sheets.get_sheet_by_share_id!(share_id)
    date_range = Sheets.get_week_range(Date.utc_today())
    render(conn, "show.html",
      id: sheet.id,
      sheet: sheet,
      habits: list_habits(sheet.id),
      date_range: date_range,
      habit_entries: all_habit_entries(sheet.id, date_range)
    )
  end

  defp list_habits(_sheet_id) do
    [] # TODO
    # Sheets.list_habits(sheet_id)
  end

  defp all_habit_entries(sheet_id, days) do
    Map.new(list_habits(sheet_id), fn habit -> {
      habit.id,
      entries_for_habit(habit.id, days)
    } end)
  end

  defp entries_for_habit(_habit_id, _days) do
    [] # TODO
    # Sheets.get_habit_entry_value_map!(habit_id, days)
  end

end
