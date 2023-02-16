defmodule HabitsheetWeb.Components do
  use HabitsheetWeb, :component

  embed_templates "components/*.html"

  attr :rest, :global, default: %{class: "w-6 h-6"}
  def icon_minus_circle_outline(assigns)

  attr :rest, :global, default: %{class: "w-6 h-6"}
  def icon_check_circle_solid(assigns)
end
