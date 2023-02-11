defmodule Habitsheet.Sheets do
  @moduledoc """
  The Sheets context.
  """

  import Ecto.Query, warn: false
  alias Habitsheet.Repo

  alias Habitsheet.Sheets.Sheet

  @doc """
  Returns the list of sheets.

  ## Examples

      iex> list_sheets()
      [%Sheet{}, ...]

  """
  def list_sheets do
    Repo.all(Sheet)
  end

  @doc """
  Gets a single sheet.

  Raises `Ecto.NoResultsError` if the Sheet does not exist.

  ## Examples

      iex> get_sheet!(123)
      %Sheet{}

      iex> get_sheet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sheet!(id), do: Repo.get!(Sheet, id)

  @doc """
  Creates a sheet.

  ## Examples

      iex> create_sheet(%{field: value})
      {:ok, %Sheet{}}

      iex> create_sheet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sheet(attrs \\ %{}) do
    %Sheet{}
    |> Sheet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sheet.

  ## Examples

      iex> update_sheet(sheet, %{field: new_value})
      {:ok, %Sheet{}}

      iex> update_sheet(sheet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sheet(%Sheet{} = sheet, attrs) do
    sheet
    |> Sheet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sheet.

  ## Examples

      iex> delete_sheet(sheet)
      {:ok, %Sheet{}}

      iex> delete_sheet(sheet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sheet(%Sheet{} = sheet) do
    Repo.delete(sheet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sheet changes.

  ## Examples

      iex> change_sheet(sheet)
      %Ecto.Changeset{data: %Sheet{}}

  """
  def change_sheet(%Sheet{} = sheet, attrs \\ %{}) do
    Sheet.changeset(sheet, attrs)
  end

  alias Habitsheet.Sheets.Habit

  @doc """
  Returns the list of habits.

  ## Examples

      iex> list_habits()
      [%Habit{}, ...]

  """
  def list_habits(sheet_id) do
    Repo.all(
      from habit in Habit,
      select: habit,
      where: habit.sheet_id == ^sheet_id
    )
  end



  @doc """
  Gets a single habit.

  Raises `Ecto.NoResultsError` if the Habit does not exist.

  ## Examples

      iex> get_habit!(123)
      %Habit{}

      iex> get_habit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_habit!(id), do: Repo.get!(Habit, id)

  @doc """
  Creates a habit.

  ## Examples

      iex> create_habit(%{field: value})
      {:ok, %Habit{}}

      iex> create_habit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_habit(attrs \\ %{}) do
    %Habit{}
    |> Habit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a habit.

  ## Examples

      iex> update_habit(habit, %{field: new_value})
      {:ok, %Habit{}}

      iex> update_habit(habit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_habit(%Habit{} = habit, attrs) do
    habit
    |> Habit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a habit.

  ## Examples

      iex> delete_habit(habit)
      {:ok, %Habit{}}

      iex> delete_habit(habit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_habit(%Habit{} = habit) do
    Repo.delete(habit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking habit changes.

  ## Examples

      iex> change_habit(habit)
      %Ecto.Changeset{data: %Habit{}}

  """
  def change_habit(%Habit{} = habit, attrs \\ %{}) do
    Habit.changeset(habit, attrs)
  end

  alias Habitsheet.Sheets.HabitEntry

  @doc """
  Returns the list of habit_entries.

  ## Examples

      iex> list_habit_entries()
      [%HabitEntry{}, ...]

  """
  def list_habit_entries do
    Repo.all(HabitEntry)
  end

  @doc """
  Gets a single habit_entry.

  Raises `Ecto.NoResultsError` if the Habit entry does not exist.

  ## Examples

      iex> get_habit_entry!(123)
      %HabitEntry{}

      iex> get_habit_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_habit_entry!(id), do: Repo.get!(HabitEntry, id)

  @doc """
  Creates a habit_entry.

  ## Examples

      iex> create_habit_entry(%{field: value})
      {:ok, %HabitEntry{}}

      iex> create_habit_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_habit_entry(attrs \\ %{}) do
    %HabitEntry{}
    |> HabitEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a habit_entry.

  ## Examples

      iex> update_habit_entry(habit_entry, %{field: new_value})
      {:ok, %HabitEntry{}}

      iex> update_habit_entry(habit_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_habit_entry(%HabitEntry{} = habit_entry, attrs) do
    habit_entry
    |> HabitEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a habit_entry.

  ## Examples

      iex> delete_habit_entry(habit_entry)
      {:ok, %HabitEntry{}}

      iex> delete_habit_entry(habit_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_habit_entry(%HabitEntry{} = habit_entry) do
    Repo.delete(habit_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking habit_entry changes.

  ## Examples

      iex> change_habit_entry(habit_entry)
      %Ecto.Changeset{data: %HabitEntry{}}

  """
  def change_habit_entry(%HabitEntry{} = habit_entry, attrs \\ %{}) do
    HabitEntry.changeset(habit_entry, attrs)
  end

  def update_habit_entry_for_date(habit_id, date, value) do
    # TODO -- need to update rollup statistics as well
    %HabitEntry{}
    |> HabitEntry.changeset(%{
      habit_id: habit_id,
      date: date,
      value: value
    })
    |> Repo.insert!(on_conflict: :replace_all, conflict_target: [:habit_id, :date])
  end

  def get_habit_entries_for_week(habit_id) do
    today = Date.utc_today()
    Repo.all(
      from entry in HabitEntry,
      select: entry,
      where: entry.habit_id == ^habit_id
         and entry.date >= ^Date.beginning_of_week(today)
         and entry.date <= ^Date.end_of_week(today)
      )
  end

  def get_habit_entry_value_map_for_week(habit_id) do
    Map.new(get_habit_entries_for_week(habit_id), fn entry -> { entry.date, entry.value } end)
  end

  def get_week_days() do
    today = Date.utc_today()
    Date.range(
      Date.beginning_of_week(today),
      Date.end_of_week(today)
    )
  end
end
