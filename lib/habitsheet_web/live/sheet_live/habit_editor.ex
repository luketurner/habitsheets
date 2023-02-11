defmodule HabitsheetWeb.SheetLive.HabitEditor do
  use HabitsheetWeb, :live_component

  alias Habitsheet.Sheets

  @impl true
  def update(%{habit: habit} = assigns, socket) do
    changeset = Sheets.change_habit(habit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"habit" => habit}, socket) do
    changeset =
      socket.assigns.habit
      |> Sheets.change_habit(habit)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"habit" => habit_params}, socket) do
    save_habit(socket, socket.assigns.action, habit_params)
  end

  defp save_habit(socket, :edit_habit, habit_params) do
    case Sheets.update_habit(socket.assigns.habit, habit_params) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit updated")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_habit(socket, :new_habit, habit_params) do
    case Sheets.create_habit(Map.put(habit_params, "sheet_id", socket.assigns.sheet_id)) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit created")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
