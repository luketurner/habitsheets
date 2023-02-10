defmodule Habitsheet.Statistics.HabitStatistic do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Sheets.Habit

  schema "habit_statistics" do
    field :end, :date
    field :range, Ecto.Enum, values: [:day, :week, :month, :year]
    field :start, :date
    field :value_count, :integer
    field :value_mean, :float
    field :value_sum, :integer
    field :value_type, Ecto.Enum, values: [:task, :count, :measure]

    belongs_to :habit, Habit
    timestamps()
  end

  @doc false
  def changeset(habit_statistic, attrs) do
    habit_statistic
    |> cast(attrs, [:value_type, :range, :start, :end, :value_count, :value_sum, :value_mean])
    |> validate_required([:value_type, :range, :start, :end, :value_count, :value_sum, :value_mean])
  end
end
