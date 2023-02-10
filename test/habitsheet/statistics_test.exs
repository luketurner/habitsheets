defmodule Habitsheet.StatisticsTest do
  use Habitsheet.DataCase

  alias Habitsheet.Statistics

  describe "habit_statistics" do
    alias Habitsheet.Statistics.HabitStatistic

    import Habitsheet.StatisticsFixtures

    @invalid_attrs %{end: nil, range: nil, start: nil, value_count: nil, value_mean: nil, value_sum: nil, value_type: nil}

    test "list_habit_statistics/0 returns all habit_statistics" do
      habit_statistic = habit_statistic_fixture()
      assert Statistics.list_habit_statistics() == [habit_statistic]
    end

    test "get_habit_statistic!/1 returns the habit_statistic with given id" do
      habit_statistic = habit_statistic_fixture()
      assert Statistics.get_habit_statistic!(habit_statistic.id) == habit_statistic
    end

    test "create_habit_statistic/1 with valid data creates a habit_statistic" do
      valid_attrs = %{end: ~D[2023-02-08], range: :day, start: ~D[2023-02-08], value_count: 42, value_mean: 120.5, value_sum: 42, value_type: :task}

      assert {:ok, %HabitStatistic{} = habit_statistic} = Statistics.create_habit_statistic(valid_attrs)
      assert habit_statistic.end == ~D[2023-02-08]
      assert habit_statistic.range == :day
      assert habit_statistic.start == ~D[2023-02-08]
      assert habit_statistic.value_count == 42
      assert habit_statistic.value_mean == 120.5
      assert habit_statistic.value_sum == 42
      assert habit_statistic.value_type == :task
    end

    test "create_habit_statistic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Statistics.create_habit_statistic(@invalid_attrs)
    end

    test "update_habit_statistic/2 with valid data updates the habit_statistic" do
      habit_statistic = habit_statistic_fixture()
      update_attrs = %{end: ~D[2023-02-09], range: :week, start: ~D[2023-02-09], value_count: 43, value_mean: 456.7, value_sum: 43, value_type: :count}

      assert {:ok, %HabitStatistic{} = habit_statistic} = Statistics.update_habit_statistic(habit_statistic, update_attrs)
      assert habit_statistic.end == ~D[2023-02-09]
      assert habit_statistic.range == :week
      assert habit_statistic.start == ~D[2023-02-09]
      assert habit_statistic.value_count == 43
      assert habit_statistic.value_mean == 456.7
      assert habit_statistic.value_sum == 43
      assert habit_statistic.value_type == :count
    end

    test "update_habit_statistic/2 with invalid data returns error changeset" do
      habit_statistic = habit_statistic_fixture()
      assert {:error, %Ecto.Changeset{}} = Statistics.update_habit_statistic(habit_statistic, @invalid_attrs)
      assert habit_statistic == Statistics.get_habit_statistic!(habit_statistic.id)
    end

    test "delete_habit_statistic/1 deletes the habit_statistic" do
      habit_statistic = habit_statistic_fixture()
      assert {:ok, %HabitStatistic{}} = Statistics.delete_habit_statistic(habit_statistic)
      assert_raise Ecto.NoResultsError, fn -> Statistics.get_habit_statistic!(habit_statistic.id) end
    end

    test "change_habit_statistic/1 returns a habit_statistic changeset" do
      habit_statistic = habit_statistic_fixture()
      assert %Ecto.Changeset{} = Statistics.change_habit_statistic(habit_statistic)
    end
  end

  describe "habit_statistics" do
    alias Habitsheet.Statistics.HabitStatistic

    import Habitsheet.StatisticsFixtures

    @invalid_attrs %{}

    test "list_habit_statistics/0 returns all habit_statistics" do
      habit_statistic = habit_statistic_fixture()
      assert Statistics.list_habit_statistics() == [habit_statistic]
    end

    test "get_habit_statistic!/1 returns the habit_statistic with given id" do
      habit_statistic = habit_statistic_fixture()
      assert Statistics.get_habit_statistic!(habit_statistic.id) == habit_statistic
    end

    test "create_habit_statistic/1 with valid data creates a habit_statistic" do
      valid_attrs = %{}

      assert {:ok, %HabitStatistic{} = habit_statistic} = Statistics.create_habit_statistic(valid_attrs)
    end

    test "create_habit_statistic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Statistics.create_habit_statistic(@invalid_attrs)
    end

    test "update_habit_statistic/2 with valid data updates the habit_statistic" do
      habit_statistic = habit_statistic_fixture()
      update_attrs = %{}

      assert {:ok, %HabitStatistic{} = habit_statistic} = Statistics.update_habit_statistic(habit_statistic, update_attrs)
    end

    test "update_habit_statistic/2 with invalid data returns error changeset" do
      habit_statistic = habit_statistic_fixture()
      assert {:error, %Ecto.Changeset{}} = Statistics.update_habit_statistic(habit_statistic, @invalid_attrs)
      assert habit_statistic == Statistics.get_habit_statistic!(habit_statistic.id)
    end

    test "delete_habit_statistic/1 deletes the habit_statistic" do
      habit_statistic = habit_statistic_fixture()
      assert {:ok, %HabitStatistic{}} = Statistics.delete_habit_statistic(habit_statistic)
      assert_raise Ecto.NoResultsError, fn -> Statistics.get_habit_statistic!(habit_statistic.id) end
    end

    test "change_habit_statistic/1 returns a habit_statistic changeset" do
      habit_statistic = habit_statistic_fixture()
      assert %Ecto.Changeset{} = Statistics.change_habit_statistic(habit_statistic)
    end
  end
end
