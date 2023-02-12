defmodule HabitsheetWeb.SharedSheetView do
  use HabitsheetWeb, :view

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

  defp get_habit_entry_for_date(habit_entries, habit_id, date) do
    habit_entries
    |> Map.get(habit_id, Map.new())
    |> Map.get(date, 0)
  end
end
