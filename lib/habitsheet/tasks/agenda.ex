defmodule Habitsheet.Tasks.Agenda do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habitsheet.Repo

  alias Habitsheet.Tasks.Task
  alias Habitsheet.Users.User

  schema "agendas" do
    field :date, :date

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
    |> cast(attrs, [:date, :user_id])
    |> validate_required([:date, :user_id])
  end

  def assoc_tasks(%__MODULE__{} = agenda, tasks) do
    Repo.insert_all("agendas_tasks", Enum.map(tasks, fn task ->
      %{task_id: task.id, agenda_id: agenda.id}
    end), conflict_target: [:agenda_id, :task_id], on_conflict: :nothing)
  end
end
