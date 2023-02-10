defmodule HabitsheetWeb.HabitStatisticLive.FormComponent do
  use HabitsheetWeb, :live_component

  alias Habitsheet.Statistics

  @impl true
  def update(%{habit_statistic: habit_statistic} = assigns, socket) do
    changeset = Statistics.change_habit_statistic(habit_statistic)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"habit_statistic" => habit_statistic_params}, socket) do
    changeset =
      socket.assigns.habit_statistic
      |> Statistics.change_habit_statistic(habit_statistic_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"habit_statistic" => habit_statistic_params}, socket) do
    save_habit_statistic(socket, socket.assigns.action, habit_statistic_params)
  end

  defp save_habit_statistic(socket, :edit, habit_statistic_params) do
    case Statistics.update_habit_statistic(socket.assigns.habit_statistic, habit_statistic_params) do
      {:ok, _habit_statistic} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit statistic updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_habit_statistic(socket, :new, habit_statistic_params) do
    case Statistics.create_habit_statistic(habit_statistic_params) do
      {:ok, _habit_statistic} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit statistic created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
