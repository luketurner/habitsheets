defmodule Habitsheet.Sheets.Habit do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @behaviour Bodyguard.Schema

  alias Habitsheet.Sheets.Sheet
  alias Habitsheet.Sheets.HabitEntry
  alias Habitsheet.Users.User

  schema "habits" do
    field :name, :string

    belongs_to :user, User
    belongs_to :sheet, Sheet, type: :binary_id
    has_many :entry, HabitEntry

    field :archived_at, :naive_datetime

    timestamps()
  end

  def scope(query, %User{id: user_id}, _) do
    from habit in query, where: habit.user_id == ^user_id
  end

  @doc false
  def create_changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :sheet_id, :user_id, :archived_at])
    |> validate_required([:name, :sheet_id, :user_id])
  end

  def update_changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :archived_at])
  end
end
