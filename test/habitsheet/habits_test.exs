defmodule Habitsheet.HabitsTest do
  use Habitsheet.DataCase, async: true

  alias Habitsheet.Habits

  import Habitsheet.HabitsFixtures

  describe "create_habit/1" do
    test "should create a habit with just name and user_id" do
      {:ok, _habit} = Habits.create_habit(create_habit_changeset())
    end

    test "should create a habit with embedded fields" do
      {:ok, _habit} =
        Habits.create_habit(
          create_habit_changeset(%{
            recurrence: [%{type: :weekly, every: 1, start: ~D[2022-03-05]}],
            notes: %{format: :md, content: "*Hi there*"},
            triggers: [%{}],
            additional_data_spec: [
              %{
                id: Ecto.UUID.generate(),
                data_type: :count,
                default_value: "0",
                label: "Test data",
                display_order: 1
              }
            ]
          })
        )
    end
  end
end
