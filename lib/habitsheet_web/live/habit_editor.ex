defmodule HabitsheetWeb.Live.HabitEditor do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Habits
  alias Habitsheet.Habits.Habit

  @impl true
  def mount(_params, _session, %{assigns: %{live_action: :new}} = socket) do
    new_habit = %Habit{}

    {:ok,
     socket
     |> assign(:changeset, Habits.habit_create_changeset(new_habit))
     |> assign(:habit, new_habit)}
  end

  @impl true
  def mount(%{"habit_id" => habit_id}, _session, %{assigns: %{live_action: :edit}} = socket) do
    with {:ok, habit} <- Habits.get_habit_as(socket.assigns.current_user, habit_id) do
      {:ok,
       socket
       |> assign(:changeset, Habits.habit_update_changeset(habit))
       |> assign(:habit, habit)}
    end
  end

  @impl true
  def handle_event("validate", %{"habit" => habit_params}, socket) do
    changeset =
      if socket.assigns.live_action == :new do
        Habits.habit_create_changeset(socket.assigns.habit, habit_params)
      else
        Habits.habit_update_changeset(socket.assigns.habit, habit_params)
      end

    changeset = Map.put(changeset, :action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"habit" => habit_params}, socket) do
    save_habit(socket, socket.assigns.live_action, habit_params)
  end

  defp save_habit(socket, :edit, habit_params) do
    case Habits.update_habit_as(
           socket.assigns.current_user,
           Habits.habit_update_changeset(socket.assigns.habit, habit_params)
         ) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit updated")
         |> push_redirect(to: Routes.habit_list_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_habit(socket, :new, habit_params) do
    changeset =
      Habits.habit_create_changeset(
        socket.assigns.habit,
        habit_params
        |> Map.put("user_id", socket.assigns.current_user.id)
      )

    case Habits.create_habit_as(socket.assigns.current_user, changeset) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit created")
         |> push_redirect(to: Routes.habit_list_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
