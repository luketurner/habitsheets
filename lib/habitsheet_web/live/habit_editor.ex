defmodule HabitsheetWeb.Live.HabitEditor do
  use HabitsheetWeb, :live_view

  alias Ecto.Changeset

  alias Habitsheet.Habits
  alias Habitsheet.Habits.AdditionalDataSpec
  alias Habitsheet.Habits.RecurringInterval
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
    # TODO -- this is necessary because if no additional_data_specs are specified,
    # the habit_params, and therefore the changeset, won't have any changes when the last spec is deleted.
    # When in fact, we do want there to be a change, which is to empty out the list.
    habit_params =
      if socket.assigns[:spec_deleted?],
        do: Map.put_new(habit_params, "additional_data_spec", []),
        else: habit_params

    habit_params =
      if socket.assigns[:recurrence_deleted?],
        do: Map.put_new(habit_params, "recurrence", []),
        else: habit_params

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
      AdditionalDataSpec.changeset(%AdditionalDataSpec{id: Ecto.UUID.generate()}, %{
        label: "Label me",
        data_type: :count
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

    {:noreply, socket |> assign(:changeset, changeset) |> assign(:spec_deleted?, true)}
  end

  @impl true
  def handle_event("add_recurrence", _, socket) do
    changeset = socket.assigns.changeset

    new_recurrence =
      RecurringInterval.changeset(%RecurringInterval{}, %{
        type: :weekly,
        every: 1,
        start: DateHelpers.today(socket.assigns.timezone)
      })

      IO.inspect(new_recurrence)

    existing = Changeset.get_field(changeset, :recurrence, [])

    changeset =
      Changeset.put_embed(changeset, :recurrence, existing ++ [new_recurrence])

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("delete_recurrence", %{"id" => id}, socket) do
    changeset = socket.assigns.changeset

    existing = Changeset.get_field(changeset, :recurrence, [])
    new = Enum.reject(existing, &(&1.id == id))

    changeset = Changeset.put_embed(changeset, :recurrence, new)

    {:noreply, socket |> assign(:changeset, changeset) |> assign(:recurrence_deleted?, true)}
  end

  defp save_habit(socket, :edit, habit_params) do
    # TODO -- this is necessary because if no additional_data_specs are specified,
    # the habit_params, and therefore the changeset, won't have any changes when the last spec is deleted.
    # When in fact, we do want there to be a change, which is to empty out the list.
    habit_params =
      if socket.assigns[:spec_deleted?],
        do: Map.put_new(habit_params, "additional_data_spec", []),
        else: habit_params

    habit_params =
      if socket.assigns[:recurrence_deleted?],
        do: Map.put_new(habit_params, "recurrence", []),
        else: habit_params

    changeset = Habit.update_changeset(socket.assigns.habit, habit_params)

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
