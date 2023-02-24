defmodule Habitsheet.Sheets.HabitEntry do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @behaviour Bodyguard.Schema

  alias Habitsheet.Sheets.Habit
  alias Habitsheet.Users.User

  schema "habit_entries" do
    field :date, :date
    field :value, :integer

    belongs_to :habit, Habit

    timestamps()
  end

  # TODO -- is using a join for this a good approach?
  def scope(query, %User{id: user_id}, _) do
    from entry in query, join: habit in Habit, where: habit.user_id == ^user_id
  end

  @doc false
  def create_changeset(habit_entry, attrs) do
    habit_entry
    |> cast(attrs, [:date, :value, :habit_id])
    |> validate_required([:date, :value, :habit_id])
  end

  def update_changeset(habit_entry, attrs) do
    habit_entry
    |> cast(attrs, [:value])
  end
end
