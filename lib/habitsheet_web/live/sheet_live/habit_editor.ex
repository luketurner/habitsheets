defmodule HabitsheetWeb.SheetLive.HabitEditor do
  use HabitsheetWeb, :live_component

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Habit

  @impl true
  def update(%{habit: %Habit{} = habit} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Sheets.change_habit(habit))}
  end

  @impl true
  def update(%{action: :new_habit} = assigns, socket) do
    new_habit = %Habit{}
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:habit, new_habit)
     |> assign(:changeset, Sheets.change_habit(new_habit))}
  end

  @impl true
  def handle_event("validate", %{"habit" => habit_params}, socket) do
    changeset =
      socket.assigns.habit
      |> Sheets.change_habit(habit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"habit" => habit_params}, socket) do
    save_habit(socket, socket.assigns.action, habit_params)
  end

  defp save_habit(socket, :edit_habit, habit_params) do
    # TODO -- update_habit! throws exceptions. I should implement a non-exception-throwing version.
    case Sheets.update_habit!(socket.assigns.current_user.id, socket.assigns.habit, habit_params) do
      _ -> #{:ok, _habit}
        {:noreply,
         socket
         |> put_flash(:info, "Habit updated")
         |> push_redirect(to: socket.assigns.return_to)}

      # {:error, %Ecto.Changeset{} = changeset} ->
      #   {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_habit(socket, :new_habit, habit_params) do
    case Sheets.create_habit(socket.assigns.current_user.id, Map.put(habit_params, "sheet_id", socket.assigns.sheet_id)) do
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
