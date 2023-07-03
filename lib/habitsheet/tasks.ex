defmodule Habitsheet.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Habitsheet.Repo

  alias Habitsheet.Tasks.Task
  alias Habitsheet.Users.User
  alias Habitsheet.Tasks.Agenda

  @behaviour Bodyguard.Policy

  def authorize(:get_task, %User{id: user_id}, %Task{user_id: user_id}), do: :ok

  def authorize(:list_tasks_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok
  def authorize(:delete_tasks_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok
  def authorize(:reorder_tasks_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok

  # Tasks can only be edited by their owner
  def authorize(:update_task, %User{id: user_id}, %Task{user_id: user_id}), do: :ok
  def authorize(:delete_task, %User{id: user_id}, %Task{user_id: user_id}), do: :ok
  def authorize(:archive_task, %User{id: user_id}, %Task{user_id: user_id}), do: :ok
  def authorize(:unarchive_task, %User{id: user_id}, %Task{user_id: user_id}), do: :ok

  # Any logged-in user can create a task, but only for themselves
  def authorize(:create_task, %User{id: user_id}, %Changeset{data: %Task{}, changes: %{user_id: user_id}}),
    do: :ok

  # Agendas
  def authorize(:list_agendas_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok
  def authorize(:build_agendas_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok
  # def authorize(:get_agenda, %User{id: user_id}, %Agenda{user_id: user_id}), do: :ok
  # def authorize(:update_agenda, %User{id: user_id}, %Agenda{user_id: user_id}), do: :ok

  # def authorize(:create_agenda, %User{id: user_id}, %Changeset{data: %Agenda{}, changes: %{user_id: user_id}}),
  #   do: :ok


  # Fallback policy
  def authorize(_, _, _), do: :error

  def get_task(id) do
    case Repo.get(Task, id) do
      nil -> {:error, :not_found}
      task -> {:ok, task}
    end
  end

  def get_task_as(%User{} = current_user, id) do
    with(
      {:ok, task} <- get_task(id),
      :ok <- Bodyguard.permit(__MODULE__, :get_task, current_user, task)
    ) do
      {:ok, task}
    end
  end

  def list_tasks_for_user(%User{} = user) do
    {:ok,
     Repo.all(
       from task in Task,
         select: task,
         where:
           task.user_id == ^user.id and
             is_nil(task.archived_at),
         order_by: [asc_nulls_last: task.display_order]
     )}
  end

  def list_tasks_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(__MODULE__, :list_tasks_for_user, current_user, user) do
      list_tasks_for_user(user)
    end
  end

  def list_archived_tasks_for_user(%User{} = user) do
    {:ok,
     Repo.all(
       from task in Task,
         select: task,
         where:
           task.user_id == ^user.id and
             not is_nil(task.archived_at)
     )}
  end

  def list_archived_tasks_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(__MODULE__, :list_tasks_for_user, current_user, user) do
      list_archived_tasks_for_user(user)
    end
  end

  def list_incomplete_tasks_for_user(%User{} = user) do
    {:ok,
     Repo.all(
       from task in Task,
         select: task,
         where:
           task.user_id == ^user.id and
             is_nil(task.archived_at) and
             is_nil(task.completed_at),
         order_by: [asc_nulls_last: task.display_order]
     )}
  end

  def list_incomplete_tasks_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(__MODULE__, :list_tasks_for_user, current_user, user) do
      list_incomplete_tasks_for_user(user)
    end
  end

  def list_complete_tasks_for_user(%User{} = user) do
    {:ok,
     Repo.all(
       from task in Task,
         select: task,
         where:
           task.user_id == ^user.id and
             is_nil(task.archived_at) and
             not is_nil(task.completed_at),
         order_by: [asc_nulls_last: task.display_order]
     )}
  end

  def list_complete_tasks_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(__MODULE__, :list_tasks_for_user, current_user, user) do
      list_complete_tasks_for_user(user)
    end
  end

  def delete_tasks_for_user(%User{id: user_id}) do
    {:ok,
     Repo.delete_all(
       from task in Task,
         where: task.user_id == ^user_id
     )}
  end

  def delete_tasks_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(__MODULE__, :delete_tasks_for_user, current_user, user) do
      delete_tasks_for_user(user)
    end
  end

  def task_update_changeset(%Task{} = task, attrs \\ %{}) do
    Task.update_changeset(task, attrs)
  end

  def task_create_changeset(%Task{} = task, attrs \\ %{}) do
    Task.create_changeset(task, attrs)
  end

  def create_task(%Changeset{data: %Task{}} = changeset) do
    # TODO...
    with(
      {:ok, data} <- Ecto.Changeset.apply_action(changeset, :update),
      timestamp = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
      {1, [task]} <-
        Repo.insert_all(
          Task,
          [
            data
            |> Map.take(Task.__schema__(:fields))
            |> Map.drop([:id])
            |> Map.put(
              :display_order,
              from(h in Task,
                select: coalesce(max(h.display_order) + 1, 0),
                where: h.user_id == ^data.user_id and is_nil(h.archived_at)
              )
            )
            |> Map.put(:inserted_at, timestamp)
            |> Map.put(:updated_at, timestamp)
          ],
          returning: true
        )
    ) do
      {:ok, task}
    end
  end

  def create_task_as(%User{} = current_user, %Changeset{data: %Task{}} = task) do
    with :ok <- Bodyguard.permit(__MODULE__, :create_task, current_user, task) do
      create_task(task)
    end
  end

  def update_task(%Changeset{data: %Task{}} = changeset) do
    Repo.update(changeset)
  end

  def update_task_as(%User{} = current_user, %Changeset{data: %Task{}} = changeset) do
    with :ok <- Bodyguard.permit(__MODULE__, :update_task, current_user, changeset.data) do
      update_task(changeset)
    end
  end

  def archive_task(%Task{} = task) do
    update_task(
      task_update_changeset(task, %{
        archived_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      })
    )
  end

  def archive_task_as(%User{} = current_user, %Task{} = task) do
    with :ok <- Bodyguard.permit(__MODULE__, :archive_task, current_user, task) do
      archive_task(task)
    end
  end

  def unarchive_task(%Task{} = task) do
    # TODO - multi me, I guess?
    next_display_order =
      Repo.one!(
        from h in Task,
          select: coalesce(max(h.display_order) + 1, 0),
          where: h.user_id == ^task.user_id and is_nil(h.archived_at)
      )

    update_task(
      task_update_changeset(task, %{
        archived_at: nil,
        display_order: next_display_order
      })
    )
  end

  def unarchive_task_as(%User{} = current_user, %Task{} = task) do
    with :ok <- Bodyguard.permit(__MODULE__, :unarchive_task, current_user, task) do
      unarchive_task(task)
    end
  end

  def reorder_task_as(%User{} = current_user, %User{} = user, %Task{} = task, new_position) do
    with :ok <- Bodyguard.permit(__MODULE__, :reorder_tasks_for_user, current_user, user) do
      reorder_task(user, task, new_position)
    end
  end

  def reorder_task(%User{} = user, %Task{} = task, new_position) do
    old_position = task.display_order

    # TODO -- this should be in a multi
    if new_position < old_position do
      # handle upward moves
      Repo.update_all(
        from(h in Task,
          where:
            h.display_order < ^old_position and h.display_order >= ^new_position and
              is_nil(h.archived_at)
        )
        |> Bodyguard.scope(user),
        inc: [display_order: 1]
      )
    else
      # handle downward moves
      Repo.update_all(
        from(h in Task,
          where:
            h.display_order > ^old_position and h.display_order <= ^new_position and
              is_nil(h.archived_at)
        )
        |> Bodyguard.scope(user),
        inc: [display_order: -1]
      )
    end

    # update the thing itself
    Repo.update_all(
      from(h in Task, where: h.id == ^task.id)
      |> Bodyguard.scope(user),
      set: [display_order: new_position]
    )

    {:ok}
  end

  def list_agendas_for_user(%User{} = user, %Date.Range{} = dates) do
    {:ok,
     Repo.all(
       from agenda in Agenda,
         select: agenda,
         where:
          agenda.user_id == ^user.id and
          agenda.date >= ^dates.first and
          agenda.date <= ^dates.last,
         order_by: [asc: agenda.date]
     )}
  end

  def list_agendas_for_user_as(%User{} = current_user, %User{} = user, %Date.Range{} = dates) do
    with :ok <- Bodyguard.permit(__MODULE__, :list_agendas_for_user, current_user, user) do
      list_agendas_for_user(user, dates)
    end
  end

  def pick_tasks_for_agenda(agenda, tasks) do
    num_important_tasks = 2 - Enum.count(agenda.tasks, &(&1.important && !&1.urgent))
    num_other_tasks = 2 - Enum.count(agenda.tasks, &(!&1.important && !&1.urgent))
    applicable_tasks = Enum.filter(tasks, &(!agenda.last_checked_at || NaiveDateTime.compare(&1.inserted_at, agenda.last_checked_at)) == :gt)
    urgent_tasks = applicable_tasks |> Enum.filter(&(&1.urgent))
    important_tasks = if num_important_tasks > 0 do
      applicable_tasks |> Stream.filter(&(&1.important && !&1.urgent)) |> Enum.shuffle() |> Enum.take(num_important_tasks)
    else
      []
    end
    other_tasks = if num_other_tasks > 0 do
      applicable_tasks |> Stream.filter(&(!&1.important && !&1.urgent)) |> Enum.shuffle() |> Enum.take(num_other_tasks)
    else
      []
    end
    urgent_tasks ++ important_tasks ++ other_tasks
  end

  def build_agendas(%User{} = user, %Date.Range{} = dates) do
    now = NaiveDateTime.utc_now()
    {:ok, all_tasks} = list_incomplete_tasks_for_user(user)
    {:ok, Enum.map(dates, fn date ->

      if existing_agenda = Repo.one(from a in Agenda, where: a.date == ^date and a.user_id == ^user.id) do

        existing_agenda = Repo.preload(existing_agenda, :tasks)

        Agenda.assoc_tasks(existing_agenda, pick_tasks_for_agenda(existing_agenda, all_tasks))

        {:ok, existing_agenda} = existing_agenda
          |> Agenda.update_changeset(%{last_checked_at: now})
          |> Repo.update()

        Repo.preload(existing_agenda, :tasks)

      else
        {:ok, agenda} = %Agenda{}
          |> Agenda.create_changeset(%{
            user_id: user.id,
            date: date,
            last_checked_at: now
          })
          |> Repo.insert(returning: true)

        urgent_tasks = Enum.filter(all_tasks, &(&1.urgent))
        important_tasks = all_tasks |> Enum.filter(&(&1.important && !&1.urgent)) |> Enum.shuffle() |> Enum.take(2)
        other_tasks = all_tasks |> Enum.filter(&(!&1.important && !&1.urgent)) |> Enum.shuffle() |> Enum.take(2)
        agenda_tasks = urgent_tasks ++ important_tasks ++ other_tasks
        Agenda.assoc_tasks(agenda, agenda_tasks)
        %{agenda | tasks: agenda_tasks}
      end
    end)}
  end

  def build_agendas_as(%User{} = current_user, %User{} = user, %Date.Range{} = dates) do
    with :ok <- Bodyguard.permit(__MODULE__, :build_agendas_for_user, current_user, user) do
      build_agendas(user, dates)
    end
  end
end
