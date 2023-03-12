defmodule Habitsheet.Habits.HabitEntry do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @behaviour Bodyguard.Schema

  alias Habitsheet.Habits.Habit
  alias Habitsheet.Users.User
  alias Habitsheet.Habits.AdditionalData

  schema "habit_entries" do
    field :date, :date
    field :additional_data, {:map, AdditionalData}

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
    |> cast(attrs, [:date, :additional_data, :habit_id])
    |> validate_required([:date, :habit_id])
  end

  def update_changeset(habit_entry, attrs) do
    habit_entry
    |> cast(attrs, [:additional_data])
  end
end
