defmodule HabitsheetWeb.Live.DailyView do
  use HabitsheetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
