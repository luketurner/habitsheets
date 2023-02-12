defmodule Habitsheet.Sheets do
  @moduledoc """
  The Sheets context.
  """

  import Ecto.Query, warn: false
  alias Habitsheet.Repo

  alias Habitsheet.Sheets.Sheet
  alias Habitsheet.Sheets.Habit
  alias Habitsheet.Sheets.HabitEntry

  @doc """
  Returns the list of sheets.

  ## Examples

      iex> list_sheets()
      [%Sheet{}, ...]

  """
  def list_sheets(user_id) do
    Repo.all(
      from s in Sheet,
      select: s,
      where: s.user_id == ^user_id
    )
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

  def get_sheet_by_share_id!(id), do: Repo.get_by!(Sheet, share_id: id)


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

  def share_sheet(%Sheet{} = sheet) do
    update_sheet(sheet, %{
      share_id: Ecto.UUID.generate()
    })
  end

  def unshare_sheet(%Sheet{} = sheet) do
    update_sheet(sheet, %{
      share_id: nil
    })
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

  def get_habit_entries(habit_id, date_range) do
    Repo.all(
      from entry in HabitEntry,
      select: entry,
      where: entry.habit_id == ^habit_id
         and entry.date >= ^date_range.first
         and entry.date <= ^date_range.last
      )
  end

  def get_habit_entry_value_map(habit_id, date_range) do
    Map.new(get_habit_entries(habit_id, date_range), fn entry -> { entry.date, entry.value } end)
  end

  def get_week_range(date) do
    Date.range(
      Date.beginning_of_week(date),
      Date.end_of_week(date)
    )
  end
end
