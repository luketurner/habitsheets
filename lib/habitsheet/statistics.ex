defmodule Habitsheet.Statistics do
  @moduledoc """
  The Statistics context.
  """

  import Ecto.Query, warn: false
  alias Habitsheet.Repo

  alias Habitsheet.Statistics.HabitStatistic

  def set_daily_statistic(date, value_type, value) do
    # TODO -- need to update rollup statistics as well
    %HabitStatistic{}
    |> HabitStatistic.changeset(%{
      start: date,
      value_type: value_type,
      value: value,
      range: "day",
      end: date
    })
    |> Repo.insert(on_conflict: :replace_all)
  end

  @doc """
  Returns the list of habit_statistics.

  ## Examples

      iex> list_habit_statistics()
      [%HabitStatistic{}, ...]

  """
  def list_habit_statistics do
    Repo.all(HabitStatistic)
  end

  @doc """
  Gets a single habit_statistic.

  Raises `Ecto.NoResultsError` if the Habit statistic does not exist.

  ## Examples

      iex> get_habit_statistic!(123)
      %HabitStatistic{}

      iex> get_habit_statistic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_habit_statistic!(id), do: Repo.get!(HabitStatistic, id)

  @doc """
  Creates a habit_statistic.

  ## Examples

      iex> create_habit_statistic(%{field: value})
      {:ok, %HabitStatistic{}}

      iex> create_habit_statistic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_habit_statistic(attrs \\ %{}) do
    %HabitStatistic{}
    |> HabitStatistic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a habit_statistic.

  ## Examples

      iex> update_habit_statistic(habit_statistic, %{field: new_value})
      {:ok, %HabitStatistic{}}

      iex> update_habit_statistic(habit_statistic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_habit_statistic(%HabitStatistic{} = habit_statistic, attrs) do
    habit_statistic
    |> HabitStatistic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a habit_statistic.

  ## Examples

      iex> delete_habit_statistic(habit_statistic)
      {:ok, %HabitStatistic{}}

      iex> delete_habit_statistic(habit_statistic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_habit_statistic(%HabitStatistic{} = habit_statistic) do
    Repo.delete(habit_statistic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking habit_statistic changes.

  ## Examples

      iex> change_habit_statistic(habit_statistic)
      %Ecto.Changeset{data: %HabitStatistic{}}

  """
  def change_habit_statistic(%HabitStatistic{} = habit_statistic, attrs \\ %{}) do
    HabitStatistic.changeset(habit_statistic, attrs)
  end

end
