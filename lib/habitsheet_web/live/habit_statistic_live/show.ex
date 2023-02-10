defmodule HabitsheetWeb.HabitStatisticLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Statistics

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:habit_statistic, Statistics.get_habit_statistic!(id))}
  end

  defp page_title(:show), do: "Show Habit statistic"
  defp page_title(:edit), do: "Edit Habit statistic"
end
