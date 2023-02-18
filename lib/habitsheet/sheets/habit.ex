defmodule Habitsheet.Sheets.Habit do
  use Ecto.Schema
  import Ecto.Changeset

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

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :sheet_id, :user_id])
    |> validate_required([:name, :sheet_id, :user_id])
  end
end
