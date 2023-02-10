defmodule Habitsheet.StatisticsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habitsheet.Statistics` context.
  """

  @doc """
  Generate a habit_statistic.
  """
  def habit_statistic_fixture(attrs \\ %{}) do
    {:ok, habit_statistic} =
      attrs
      |> Enum.into(%{
        end: ~D[2023-02-08],
        range: :day,
        start: ~D[2023-02-08],
        value_count: 42,
        value_mean: 120.5,
        value_sum: 42,
        value_type: :task
      })
      |> Habitsheet.Statistics.create_habit_statistic()

    habit_statistic
  end

  @doc """
  Generate a habit_statistic.
  """
  def habit_statistic_fixture(attrs \\ %{}) do
    {:ok, habit_statistic} =
      attrs
      |> Enum.into(%{

      })
      |> Habitsheet.Statistics.create_habit_statistic()

    habit_statistic
  end
end
