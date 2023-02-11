defmodule Habitsheet.Sheets.HabitEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Sheets.Habit

  schema "habit_entries" do
    field :date, :date
    field :value, :integer

    belongs_to :habit, Habit

    timestamps()
  end

  @doc false
  def changeset(habit_entry, attrs) do
    habit_entry
    |> cast(attrs, [:date, :value, :habit_id])
    |> validate_required([:date, :value, :habit_id])
  end
end
