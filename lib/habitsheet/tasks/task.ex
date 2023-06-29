defmodule Habitsheet.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Habitsheet.Users.User
  alias Habitsheet.Notes

  schema "tasks" do
    field :name, :string
    field :important, :boolean, default: false
    field :urgent, :boolean, default: false
    field :display_order, :integer
    field :archived_at, :naive_datetime
    field :completed_at, :naive_datetime

    embeds_one :notes, Notes, on_replace: :delete

    belongs_to :user, User

    timestamps()
  end

  def scope(query, %User{id: user_id}, _) do
    from task in query, where: task.user_id == ^user_id
  end

  @doc false
  def create_changeset(task, attrs \\ %{}) do
    task
    |> cast(attrs, [:name, :important, :urgent, :display_order, :user_id, :archived_at, :completed_at])
    |> cast_embed(:notes)
    |> validate_required([:name, :user_id])
  end

  def update_changeset(task, attrs \\ %{}) do
    task
    |> cast(attrs, [:name, :important, :urgent, :display_order, :archived_at, :completed_at])
    |> cast_embed(:notes)
  end
end
