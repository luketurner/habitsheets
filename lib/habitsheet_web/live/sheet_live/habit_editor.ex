defmodule HabitsheetWeb.SheetLive.HabitEditor do
  use HabitsheetWeb, :live_component

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Habit

  @impl true
  def update(%{habit: %Habit{} = habit} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Sheets.habit_update_changeset(habit))}
  end

  @impl true
  def update(%{action: :new_habit} = assigns, socket) do
    new_habit = %Habit{}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:habit, new_habit)
     |> assign(:changeset, Sheets.habit_create_changeset(new_habit))}
  end

  @impl true
  def handle_event("validate", %{"habit" => habit_params}, socket) do
    changeset =
      if socket.assigns.action == :new_habit do
        Sheets.habit_create_changeset(socket.assigns.habit, habit_params)
      else
        Sheets.habit_update_changeset(socket.assigns.habit, habit_params)
      end

    changeset = Map.put(changeset, :action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"habit" => habit_params}, socket) do
    save_habit(socket, socket.assigns.action, habit_params)
  end

  @impl true
  def handle_event("archive", _params, socket) do
    Sheets.archive_habit_as(socket.assigns.current_user, socket.assigns.habit)

    {:noreply,
     socket
     |> put_flash(:info, "Habit archived")
     |> push_redirect(to: socket.assigns.return_to)}
  end

  defp save_habit(socket, :edit_habit, habit_params) do
    # TODO -- update_habit! throws exceptions. I should implement a non-exception-throwing version.
    case Sheets.update_habit_as(
           socket.assigns.current_user,
           Sheets.habit_update_changeset(socket.assigns.habit, habit_params)
         ) do
      # {:ok, _habit}
      _ ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit updated")
         |> push_redirect(to: socket.assigns.return_to)}

        # {:error, %Ecto.Changeset{} = changeset} ->
        #   {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_habit(socket, :new_habit, habit_params) do
    changeset =
      Sheets.habit_create_changeset(
        socket.assigns.habit,
        habit_params
        |> Map.put("sheet_id", socket.assigns.sheet.id)
        |> Map.put("user_id", socket.assigns.current_user.id)
      )

    case Sheets.create_habit_as(socket.assigns.current_user, changeset) do
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
