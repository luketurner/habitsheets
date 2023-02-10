defmodule HabitsheetWeb.HabitStatisticLive.Index do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Statistics
  alias Habitsheet.Statistics.HabitStatistic

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :habit_statistics, list_habit_statistics())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Habit statistic")
    |> assign(:habit_statistic, Statistics.get_habit_statistic!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Habit statistic")
    |> assign(:habit_statistic, %HabitStatistic{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Habit statistics")
    |> assign(:habit_statistic, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    habit_statistic = Statistics.get_habit_statistic!(id)
    {:ok, _} = Statistics.delete_habit_statistic(habit_statistic)

    {:noreply, assign(socket, :habit_statistics, list_habit_statistics())}
  end

  defp list_habit_statistics do
    Statistics.list_habit_statistics()
  end
end
