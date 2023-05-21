defmodule Habitsheet.HabitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habitsheet.Habits` context.
  """

  import Habitsheet.UsersFixtures
  alias Habitsheet.Habits
  alias Habitsheet.Habits.Habit

  def create_habit_attributes(attrs \\ %{}) do
    user = attrs[:user] || user_fixture()

    Enum.into(attrs, %{
      user_id: user.id,
      name: "Test Habit"
    })
  end

  def create_habit_changeset(attrs \\ %{}) do
    Habit.create_changeset(%Habit{}, create_habit_attributes(attrs))
  end

  def habit_fixture(attrs \\ %{}) do
    {:ok, habit} =
      attrs
      |> create_habit_changeset()
      |> Habits.create_habit()

    habit
  end

  def habit_entry_fixture(habit \\ nil, date \\ ~D[2023-01-01], additional_data \\ []) do
    habit = habit || habit_fixture()
    {:ok, entry} = Habits.update_habit_entry_for_date(habit, date, additional_data)
    entry
  end
end
