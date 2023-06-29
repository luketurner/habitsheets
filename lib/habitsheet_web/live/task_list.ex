defmodule HabitsheetWeb.Live.TaskList do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_tasks()}
  end

  @impl true
  def handle_event("archive", %{"id" => task_id}, socket) do
    task = get_task_from_socket(socket, task_id)

    with {:ok, _task} <- Tasks.archive_task_as(socket.assigns.current_user, task) do
      {:noreply,
       socket
       |> assign_tasks()}
    end
  end

  @impl true
  def handle_event("unarchive", %{"id" => task_id}, socket) do
    task = get_task_from_socket(socket, task_id)

    with {:ok, _task} <- Tasks.unarchive_task_as(socket.assigns.current_user, task) do
      {:noreply,
       socket
       |> assign_tasks()}
    end
  end

  @impl true
  def handle_event(
        "sortable_update",
        %{"id" => task_id, "newIndex" => new_index, "oldIndex" => old_index},
        socket
      ) do
    task = get_task_from_socket(socket, task_id)

    if old_index == task.display_order do
      with {:ok} <-
             Tasks.reorder_task_as(
               socket.assigns.current_user,
               socket.assigns.current_user,
               task,
               new_index
             ) do
        {:noreply,
         socket
         |> assign_tasks()}
      end
    else
      # Client sort order is desynced from DB
      # TODO - better logging?
      IO.puts("Client sort order is desynced from DB")
      IO.inspect(task)
      {:noreply, socket |> assign_tasks()}
    end
  end

  defp assign_tasks(socket) do
    case socket.assigns.live_action do
      :archived -> assign_archived_tasks(socket)
      :completed -> assign_completed_tasks(socket)
      _ -> assign_active_tasks(socket)
    end
  end

  defp assign_active_tasks(socket) do
    with {:ok, tasks} <-
           Tasks.list_incomplete_tasks_for_user_as(
             socket.assigns.current_user,
             socket.assigns.current_user
           ) do
      socket
      |> assign(:tasks, tasks)
    end
  end

  defp assign_archived_tasks(socket) do
    with {:ok, tasks} <-
           Tasks.list_archived_tasks_for_user_as(
             socket.assigns.current_user,
             socket.assigns.current_user
           ) do
      socket
      |> assign(:tasks, tasks)
    end
  end

  defp assign_completed_tasks(socket) do
    with {:ok, tasks} <-
           Tasks.list_complete_tasks_for_user_as(
             socket.assigns.current_user,
             socket.assigns.current_user
           ) do
      socket
      |> assign(:tasks, tasks)
    end
  end

  defp get_task_from_socket(socket, task_id) do
    Enum.find(socket.assigns.tasks, &(to_string(&1.id) == task_id))
  end
end
