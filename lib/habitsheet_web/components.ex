defmodule HabitsheetWeb.Components do
  use HabitsheetWeb, :component

  embed_templates "components/*.html"

  attr :rest, :global, default: %{class: "w-6 h-6"}
  def icon_minus_circle_outline(assigns)

  attr :rest, :global, default: %{class: "w-6 h-6"}
  def icon_check_circle_solid(assigns)

  attr :rest, :global, default: %{class: "w-6 h-6"}
  def icon_bars_three_outline(assigns)

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
  attr :rest, :global, default: %{class: "swap"}
  # these must be specified to create new entries in case entry is nil
  attr :date, Date, default: nil
  attr :habit_id, :any, default: nil
  def habit_entry_status(assigns)

  attr :habit, Habitsheets.Sheets.Habit, required: true
  attr :date_range, DateRange, required: true
  attr :entry_map, :map, default: %{}
  attr :delete_attrs, :map, default: nil
  attr :edit_attrs, :map, default: nil
  attr :rest, :global, default: %{class: ""}
  def habit_entry_line(assigns)

  attr :date_range, DateRange, required: true
  attr :rest, :global, default: %{class: ""}
  slot :next
  slot :prev
  slot :date
  def date_heading_line(assigns)

  attr :conn_or_socket, :any, required: true
  slot :inner_block, required: true
  slot :nav_menu, required: true
  slot :nav_title, required: true
  slot :nav_subtitle
  slot :footer, required: true
  def layout(assigns)
end
