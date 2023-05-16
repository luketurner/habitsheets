defmodule Habitsheet.HabitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habitsheet.Habits` context.
  """

  alias Habitsheet.UsersFixtures
  alias Habitsheet.Habits
  alias Habitsheet.Habits.Habit

  def create_habit_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      user_id: UsersFixtures.user_fixture().id,
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
end
