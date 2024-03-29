defmodule Habitsheet.Agendas.Agenda do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habitsheet.Repo

  alias Habitsheet.Tasks.Task
  alias Habitsheet.Users.User

  @default_overall_task_limit 5
  @default_important_task_limit 2
  @default_other_task_limit 2

  schema "agendas" do
    field :date, :date
    field :last_checked_at, :naive_datetime
    field :important_task_limit, :integer, default: @default_important_task_limit
    field :other_task_limit, :integer, default: @default_other_task_limit
    field :overall_task_limit, :integer, default: @default_overall_task_limit

    many_to_many :tasks, Task, join_through: "agendas_tasks", on_replace: :delete, unique: true

    belongs_to :user, User

    timestamps()
  end

  def scope(query, %User{id: user_id}, _) do
    from agenda in query, where: agenda.user_id == ^user_id
  end

  @doc false
  def create_changeset(agenda, attrs) do
    agenda
    |> cast(attrs, [:date, :user_id, :last_checked_at, :important_task_limit, :other_task_limit, :overall_task_limit])
    |> validate_required([:date, :user_id])
  end

  def update_changeset(agenda, attrs) do
    agenda
    |> cast(attrs, [:last_checked_at, :important_task_limit, :other_task_limit, :overall_task_limit])
  end

  def assoc_tasks(%__MODULE__{} = agenda, tasks) do
    Repo.insert_all("agendas_tasks", Enum.map(tasks, fn task ->
      %{task_id: task.id, agenda_id: agenda.id}
    end), conflict_target: [:agenda_id, :task_id], on_conflict: :nothing)
  end

  def find_task(%__MODULE__{} = agenda, task_id) when is_binary(task_id) do
    find_task(agenda, String.to_integer(task_id))
  end

  def find_task(%__MODULE__{} = agenda, task_id) when is_integer(task_id) do
    Enum.find(agenda.tasks, &(&1.id == task_id))
  end
end
