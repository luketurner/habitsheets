defmodule Habitsheet.SheetsTest do
  use Habitsheet.DataCase

  alias Habitsheet.Sheets

  describe "sheets" do
    alias Habitsheet.Sheets.Sheet

    import Habitsheet.SheetsFixtures

    @invalid_attrs %{title: nil}

    test "list_sheets/0 returns all sheets" do
      sheet = sheet_fixture()
      assert Sheets.list_sheets() == [sheet]
    end

    test "get_sheet!/1 returns the sheet with given id" do
      sheet = sheet_fixture()
      assert Sheets.get_sheet!(sheet.id) == sheet
    end

    test "create_sheet/1 with valid data creates a sheet" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Sheet{} = sheet} = Sheets.create_sheet(valid_attrs)
      assert sheet.title == "some title"
    end

    test "create_sheet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sheets.create_sheet(@invalid_attrs)
    end

    test "update_sheet/2 with valid data updates the sheet" do
      sheet = sheet_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Sheet{} = sheet} = Sheets.update_sheet(sheet, update_attrs)
      assert sheet.title == "some updated title"
    end

    test "update_sheet/2 with invalid data returns error changeset" do
      sheet = sheet_fixture()
      assert {:error, %Ecto.Changeset{}} = Sheets.update_sheet(sheet, @invalid_attrs)
      assert sheet == Sheets.get_sheet!(sheet.id)
    end

    test "delete_sheet/1 deletes the sheet" do
      sheet = sheet_fixture()
      assert {:ok, %Sheet{}} = Sheets.delete_sheet(sheet)
      assert_raise Ecto.NoResultsError, fn -> Sheets.get_sheet!(sheet.id) end
    end

    test "change_sheet/1 returns a sheet changeset" do
      sheet = sheet_fixture()
      assert %Ecto.Changeset{} = Sheets.change_sheet(sheet)
    end
  end

  describe "habits" do
    alias Habitsheet.Sheets.Habit

    import Habitsheet.SheetsFixtures

    @invalid_attrs %{name: nil}

    test "list_habits/0 returns all habits" do
      habit = habit_fixture()
      assert Sheets.list_habits() == [habit]
    end

    test "get_habit!/1 returns the habit with given id" do
      habit = habit_fixture()
      assert Sheets.get_habit!(habit.id) == habit
    end

    test "create_habit/1 with valid data creates a habit" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Habit{} = habit} = Sheets.create_habit(valid_attrs)
      assert habit.name == "some name"
    end

    test "create_habit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sheets.create_habit(@invalid_attrs)
    end

    test "update_habit/2 with valid data updates the habit" do
      habit = habit_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Habit{} = habit} = Sheets.update_habit(habit, update_attrs)
      assert habit.name == "some updated name"
    end

    test "update_habit/2 with invalid data returns error changeset" do
      habit = habit_fixture()
      assert {:error, %Ecto.Changeset{}} = Sheets.update_habit(habit, @invalid_attrs)
      assert habit == Sheets.get_habit!(habit.id)
    end

    test "delete_habit/1 deletes the habit" do
      habit = habit_fixture()
      assert {:ok, %Habit{}} = Sheets.delete_habit(habit)
      assert_raise Ecto.NoResultsError, fn -> Sheets.get_habit!(habit.id) end
    end

    test "change_habit/1 returns a habit changeset" do
      habit = habit_fixture()
      assert %Ecto.Changeset{} = Sheets.change_habit(habit)
    end
  end
end
