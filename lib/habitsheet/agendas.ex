defmodule Habitsheet.Agendas do
  @moduledoc """
  The Agendas context.
  """

  import Ecto.Query, warn: false
  alias Habitsheet.Repo

  alias Habitsheet.Tasks
  alias Habitsheet.Users.User
  alias Habitsheet.Agendas.Agenda

  @behaviour Bodyguard.Policy

  # Agendas
  def authorize(:list_agendas_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok
  def authorize(:build_agendas_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok


  # Fallback policy
  def authorize(_, _, _), do: :error

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

  def pick_tasks_for_agenda(%Agenda{overall_task_limit: overall_task_limit, important_task_limit: important_task_limit, other_task_limit: other_task_limit, tasks: agenda_tasks, last_checked_at: last_checked_at}, tasks, [allow_old_tasks: allow_old_tasks] = _opts \\ []) do
    num_overall_tasks = overall_task_limit - Enum.count(agenda_tasks)
    num_important_tasks = important_task_limit - Enum.count(agenda_tasks, &(&1.important && !&1.urgent))
    num_other_tasks = other_task_limit - Enum.count(agenda_tasks, &(!&1.important && !&1.urgent))
    applicable_tasks = Stream.filter(tasks, fn task ->
      # TODO -- O(n*m)
      !Enum.any?(agenda_tasks, &(&1.id == task.id)) &&
      (allow_old_tasks || !last_checked_at || NaiveDateTime.compare(task.inserted_at, last_checked_at) == :gt)
    end)

    # First, pick any important and urgent tasks.
    important_and_urgent_tasks = if num_overall_tasks > 0 do
      applicable_tasks |> Stream.filter(&(&1.important && &1.urgent)) |> Enum.shuffle() |> Enum.take(num_overall_tasks)
    else
      []
    end
    picked_tasks = important_and_urgent_tasks
    num_overall_tasks = num_overall_tasks - Enum.count(important_and_urgent_tasks)

    # If we still have space, pick any remaining urgent tasks.
    urgent_tasks = if num_overall_tasks > 0 do
      applicable_tasks |> Stream.filter(&(!&1.important && &1.urgent)) |> Enum.shuffle() |> Enum.take(num_overall_tasks)
    else
      []
    end
    picked_tasks = picked_tasks ++ urgent_tasks
    num_overall_tasks = num_overall_tasks - Enum.count(urgent_tasks)

    # If we still have space, and we don't have 2+ important tasks already, pick any remaining important tasks.
    important_tasks = if (num_to_take = min(num_overall_tasks, num_important_tasks)) > 0 do
      applicable_tasks |> Stream.filter(&(&1.important && !&1.urgent)) |> Enum.shuffle() |> Enum.take(num_to_take)
    else
      []
    end
    picked_tasks = picked_tasks ++ important_tasks
    num_overall_tasks = num_overall_tasks - Enum.count(important_tasks)

    # If we still have space, and we don't have enough other tasks already, pick any remaining other tasks
    other_tasks = if (num_to_take = min(num_overall_tasks, num_other_tasks)) > 0 do
      applicable_tasks |> Stream.filter(&(!&1.important && !&1.urgent)) |> Enum.shuffle() |> Enum.take(num_to_take)
    else
      []
    end
    picked_tasks = picked_tasks ++ other_tasks
    # num_overall_tasks = num_overall_tasks - Enum.count(other_tasks)

    picked_tasks
  end

  def build_agenda(%User{} = user, %Date{} = date) do
    if existing_agenda = Repo.one(from a in Agenda, where: a.date == ^date and a.user_id == ^user.id) do
      rebuild_agenda(existing_agenda, allow_old_tasks: false)
    else
      build_new_agenda(user, date)
    end
  end

  def rebuild_agenda(%Agenda{} = existing_agenda, [allow_old_tasks: allow_old_tasks] = _opts \\ []) do
    existing_agenda = Repo.preload(existing_agenda, :user)
    now = NaiveDateTime.utc_now()
    {:ok, all_tasks} = Tasks.list_incomplete_tasks_for_user(existing_agenda.user)
    existing_agenda = Repo.preload(existing_agenda, :tasks)
    Agenda.assoc_tasks(existing_agenda, pick_tasks_for_agenda(existing_agenda, all_tasks, allow_old_tasks: allow_old_tasks))
    {:ok, existing_agenda} = existing_agenda
      |> Agenda.update_changeset(%{last_checked_at: now})
      |> Repo.update()
    {:ok, Repo.preload(existing_agenda, :tasks, force: true)}
  end

  def build_new_agenda(%User{} = user, %Date{} = date) do
    now = NaiveDateTime.utc_now()
    {:ok, all_tasks} = Tasks.list_incomplete_tasks_for_user(user)
    {:ok, agenda} = %Agenda{}
      |> Agenda.create_changeset(%{
        user_id: user.id,
        date: date,
        last_checked_at: now
      })
      |> Repo.insert(returning: true)
    agenda = Repo.preload(agenda, :tasks)
    Agenda.assoc_tasks(agenda, pick_tasks_for_agenda(agenda, all_tasks, allow_old_tasks: true))
    {:ok, Repo.preload(agenda, :tasks, force: true)}
  end

  def build_agenda_as(%User{} = current_user, %User{} = user, %Date{} = date) do
    with :ok <- Bodyguard.permit(__MODULE__, :build_agendas_for_user, current_user, user) do
      build_agenda(user, date)
    end
  end

  def clear_tasks(%Agenda{} = agenda) do
    Repo.delete_all(from at in "agendas_tasks", where: at.agenda_id == ^agenda.id)
    {:ok, Ecto.reset_fields(agenda, [:tasks])}
  end

  def automatically_add_tasks(%Agenda{} = agenda, %{num_important_tasks: num_important_tasks, num_other_tasks: num_other_tasks}) do
    {:ok, agenda} = Agenda.update_changeset(agenda, %{
      important_task_limit: agenda.important_task_limit + num_important_tasks,
      other_task_limit: agenda.other_task_limit + num_other_tasks,
      overall_task_limit: agenda.overall_task_limit + num_important_tasks + num_other_tasks
    }) |> Repo.update()
    rebuild_agenda(agenda, allow_old_tasks: true)
  end

  def refresh_tasks(%Agenda{} = agenda) do
    {:ok, agenda} = clear_tasks(agenda)
    rebuild_agenda(agenda, allow_old_tasks: true)
  end
end
