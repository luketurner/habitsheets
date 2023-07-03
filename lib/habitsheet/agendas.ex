defmodule Habitsheet.Agendas do
  @moduledoc """
  The Agendas context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
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
    {:ok, all_tasks} = Tasks.list_incomplete_tasks_for_user(user)
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
