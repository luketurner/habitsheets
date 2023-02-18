defmodule HabitsheetWeb.Components do
  use HabitsheetWeb, :component

  embed_templates "components/*.html"

  attr :rest, :global, default: %{class: "w-6 h-6"}
  def icon_minus_circle_outline(assigns)

  attr :rest, :global, default: %{class: "w-6 h-6"}
  def icon_check_circle_solid(assigns)

  attr :rest, :global, default: %{class: "text-xl font-bold pb-4"}
  slot :inner_block
  def page_title(assigns)

  attr :habit, Habitsheet.Sheets.Habit
  attr :rest, :global, default: %{class: ""}
  slot :inner_block
  def habit_label(assigns)

  attr :entry, Habitsheet.Sheets.HabitEntry
  attr :readonly, :boolean, default: false
  attr :click, :any, default: nil

  # these must be specified to create new entries in case entry is nil
  attr :date, Date, default: nil
  attr :habit_id, :any, default: nil

  attr :rest, :global, default: %{class: "swap"}
  def habit_entry_status(assigns)
end
