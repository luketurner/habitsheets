defmodule HabitsheetWeb.Live.HabitEditor do
  use HabitsheetWeb, :live_view

  alias Ecto.Changeset

  alias Habitsheet.Habits
  alias Habitsheet.Habits.AdditionalDataSpec
  alias Habitsheet.Habits.Habit

  @impl true
  def mount(_params, _session, %{assigns: %{live_action: :new}} = socket) do
    new_habit = %Habit{}
    changeset = Habits.habit_create_changeset(new_habit)

    {:ok,
     socket
     |> assign(:changeset, changeset)
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

  @impl true
  def handle_event("add_spec", _, socket) do
    changeset = socket.assigns.changeset

    # TODO -- autogenerate IDs better?
    new_spec =
      AdditionalDataSpec.changeset(%AdditionalDataSpec{}, %{
        label: "Label me",
        data_type: :numeric,
        id: Ecto.UUID.generate()
      })

    existing_specs = Changeset.get_field(changeset, :additional_data_spec, [])

    changeset =
      Changeset.put_embed(changeset, :additional_data_spec, existing_specs ++ [new_spec])

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("delete_spec", %{"id" => id}, socket) do
    changeset = socket.assigns.changeset

    existing_specs = Changeset.get_field(changeset, :additional_data_spec, [])
    new_specs = Enum.reject(existing_specs, &(&1.id == id))

    changeset = Changeset.put_embed(changeset, :additional_data_spec, new_specs)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  defp save_habit(socket, :edit, habit_params) do
    changeset = Habit.update_changeset(socket.assigns.habit, habit_params)

    # TODO -- this is necessary because if no additional_data_specs are specified,
    # the habit_params, and therefore the changeset, won't have any changes. When
    # in fact, we do want there to be a change, which is to empty out the list.
    changeset =
      if Changeset.get_change(changeset, :additional_data_spec) do
        changeset
      else
        Changeset.put_embed(changeset, :additional_data_spec, [])
      end

    case Habits.update_habit_as(socket.assigns.current_user, changeset) do
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
