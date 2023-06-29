defmodule HabitsheetWeb.Live.TaskEditor do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Tasks
  alias Habitsheet.Tasks.Task

  @impl true
  def mount(_params, _session, %{assigns: %{live_action: :new}} = socket) do
    new_task = %Task{}
    changeset = Tasks.task_create_changeset(new_task)

    {:ok,
     socket
     |> assign(:changeset, changeset)
     |> assign(:task, new_task)}
  end

  @impl true
  def mount(%{"task_id" => task_id}, _session, %{assigns: %{live_action: :edit}} = socket) do
    with {:ok, task} <- Tasks.get_task_as(socket.assigns.current_user, task_id) do
      {:ok,
       socket
       |> assign(:changeset, Tasks.task_update_changeset(task))
       |> assign(:task, task)}
    end
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      if socket.assigns.live_action == :new do
        Tasks.task_create_changeset(socket.assigns.task, task_params)
      else
        Tasks.task_update_changeset(socket.assigns.task, task_params)
      end

    changeset = Map.put(changeset, :action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.live_action, task_params)
  end

  defp save_task(socket, :edit, task_params) do
    changeset = Task.update_changeset(socket.assigns.task, task_params)

    case Tasks.update_task_as(socket.assigns.current_user, changeset) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated")
         |> push_redirect(to: Routes.task_list_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_task(socket, :new, task_params) do
    changeset =
      Tasks.task_create_changeset(
        socket.assigns.task,
        task_params
        |> Map.put("user_id", socket.assigns.current_user.id)
      )

    case Tasks.create_task_as(socket.assigns.current_user, changeset) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task created")
         |> push_redirect(to: Routes.task_list_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
