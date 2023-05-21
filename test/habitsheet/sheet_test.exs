defmodule Habitsheet.SheetTest do
  use Habitsheet.DataCase, async: true

  alias Habitsheet.Sheet

  import Habitsheet.UsersFixtures
  import Habitsheet.SheetFixtures

  setup do
    user = user_fixture()

    {sheet,
     %{
       recurring_habit: recurring_habit,
       expiring_habit: expiring_habit,
       simple_habit: simple_habit
     }} = sheet_7d_fixture(user)

    %{
      user: user,
      sheet: sheet,
      recurring_habit: recurring_habit,
      expiring_habit: expiring_habit,
      simple_habit: simple_habit
    }
  end

  describe "sheet fixture" do
    test "should have the right user", %{sheet: sheet, user: user} do
      assert sheet.user == user
    end
  end

  describe "habit_shown_on/2" do
    test "should always return true for habits with neither recurrence nor expiration", %{
      sheet: sheet,
      simple_habit: habit
    } do
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-01])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-02])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-03])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-04])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-05])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-06])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-07])
    end

    test "should respect recurrence", %{
      sheet: sheet,
      recurring_habit: habit
    } do
      refute Sheet.habit_shown_on(sheet, habit, ~D[2023-01-01])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-02])
      refute Sheet.habit_shown_on(sheet, habit, ~D[2023-01-03])
      refute Sheet.habit_shown_on(sheet, habit, ~D[2023-01-04])
      refute Sheet.habit_shown_on(sheet, habit, ~D[2023-01-05])
      refute Sheet.habit_shown_on(sheet, habit, ~D[2023-01-06])
      refute Sheet.habit_shown_on(sheet, habit, ~D[2023-01-07])
    end

    test "should respect expiration", %{
      sheet: sheet,
      expiring_habit: habit
    } do
      refute Sheet.habit_shown_on(sheet, habit, ~D[2023-01-01])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-02])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-03])
      refute Sheet.habit_shown_on(sheet, habit, ~D[2023-01-04])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-05])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-06])
      assert Sheet.habit_shown_on(sheet, habit, ~D[2023-01-07])
    end
  end
end
