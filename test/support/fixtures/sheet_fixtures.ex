defmodule Habitsheet.SheetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habitsheet.Habits` context.
  """

  import Habitsheet.UsersFixtures
  import Habitsheet.HabitsFixtures
  alias Habitsheet.Sheet

  def sheet_7d_fixture(user \\ nil) do
    user = user || user_fixture()

    # Seed data for sheet to load
    habit1 =
      habit_fixture(%{
        user: user,
        name: "Test Habit 1"
      })

    habit_entry_fixture(habit1, ~D[2023-01-01])
    habit_entry_fixture(habit1, ~D[2023-01-02])
    habit_entry_fixture(habit1, ~D[2023-01-03])

    habit2 =
      habit_fixture(%{
        user: user,
        name: "Test Recurring Habit",
        recurrence: [
          %{
            type: :weekly,
            start: ~D[2023-01-09],
            every: 1
          }
        ]
      })

    habit_entry_fixture(habit2, ~D[2023-01-01])
    habit_entry_fixture(habit2, ~D[2023-01-05])

    habit3 =
      habit_fixture(%{
        user: user,
        name: "Test Expiring Habit",
        expiration: 2
      })

    habit_entry_fixture(habit3, ~D[2022-12-31])
    habit_entry_fixture(habit3, ~D[2023-01-03])

    {:ok, sheet} = Sheet.new(user, Date.range(~D[2023-01-01], ~D[2023-01-07]))

    {sheet,
     %{
       simple_habit: habit1,
       recurring_habit: habit2,
       expiring_habit: habit3
     }}
  end
end
