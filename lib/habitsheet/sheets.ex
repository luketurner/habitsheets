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

  # def list_all_sheets(), do: Repo.all(Sheet)

  @doc """
  Gets a single sheet.

  Raises `Ecto.NoResultsError` if the Sheet does not exist.

  ## Examples

      iex> get_sheet!(123)
      %Sheet{}

      iex> get_sheet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sheet!(user_id, id), do: Repo.get_by!(Sheet, [id: id, user_id: user_id])

  def get_sheet_by_share_id!(id), do: Repo.get_by!(Sheet, share_id: id)


  @doc """
  Creates a sheet.

  ## Examples

      iex> create_sheet(%{field: value})
      {:ok, %Sheet{}}

      iex> create_sheet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sheet(user_id, attrs \\ %{}) do
    %Sheet{}
    |> Sheet.changeset(Map.put(attrs, "user_id", user_id))
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
  def update_sheet(user_id, %Sheet{} = sheet, attrs) do
    if get_sheet!(user_id, sheet.id) do
      # don't allow overwriting owner
      Map.delete(attrs, :user_id)

      sheet
      |> Sheet.changeset(attrs)
      |> Repo.update()
    else
      raise "Could not find sheet"
    end
  end

  def share_sheet!(user_id, %Sheet{} = sheet) do
    update_sheet(user_id, sheet, %{
      share_id: Ecto.UUID.generate()
    })
  end

  def unshare_sheet!(user_id, %Sheet{} = sheet) do
    update_sheet(user_id, sheet, %{
      share_id: nil
    })
  end

  # def enable_daily_review_emails!(user_id, %Sheet{} = sheet) do
  #   update_sheet!(user_id, sheet, %{
  #     daily_review_email_enabled: true
  #   })
  # end

  # def disable_daily_review_emails!(user_id, %Sheet{} = sheet) do
  #   update_sheet!(user_id, sheet, %{
  #     daily_review_email_enabled: false
  #   })
  # end

  @doc """
  Deletes a sheet.

  ## Examples

      iex> delete_sheet(sheet)
      {:ok, %Sheet{}}

      iex> delete_sheet(sheet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sheet!(user_id, %Sheet{} = sheet) do
    if get_sheet!(user_id, sheet) do
      Repo.delete!(sheet)
    else
      raise "Could not find sheet"
    end
  end

  def delete_sheet_by_id!(user_id, sheet_id) do
    Repo.delete_all(from s in Sheet, where: s.id == ^sheet_id and s.user_id == ^user_id)
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
  def list_habits_for_sheet!(user_id, sheet_id) do
    if get_sheet!(user_id, sheet_id) do
      Repo.all(
        from habit in Habit,
        select: habit,
        where: habit.sheet_id == ^sheet_id and is_nil(habit.archived_at)
      )
    else
      raise "Could not find sheet"
    end
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
  def get_habit!(user_id, id), do: Repo.get_by!(Habit, [id: id, user_id: user_id])

  @doc """
  Creates a habit.

  ## Examples

      iex> create_habit(%{field: value})
      {:ok, %Habit{}}

      iex> create_habit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_habit(user_id, attrs \\ %{}) do
    %Habit{}
    |> Habit.changeset(Map.put(attrs, "user_id", user_id))
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
  def update_habit!(user_id, %Habit{} = habit, attrs) do
    if get_habit!(user_id, habit.id) do
      # don't allow overwriting owner
      Map.delete(attrs, :user_id)

      habit
      |> Habit.changeset(attrs)
      |> Repo.update!()
    else
      raise "Could not find sheet"
    end
  end

  @doc """
  Deletes a habit.

  ## Examples

      iex> delete_habit(habit)
      {:ok, %Habit{}}

      iex> delete_habit(habit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_habit!(user_id, %Habit{} = habit) do
    if get_habit!(user_id, habit.id) do
      Repo.delete!(habit)
    else
      raise "Could not find habit"
    end
  end

  def delete_habit_by_id!(user_id, habit_id) do
    Repo.delete_all(from h in Habit, where: h.id == ^habit_id and h.user_id == ^user_id)
  end

  def archive_habit_by_id!(user_id, habit_id) do
    Repo.update_all(
      from(h in Habit, where: h.id == ^habit_id and h.user_id == ^user_id),
      set: [archived_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)]
    )
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

  def update_habit_entry_for_date!(user_id, habit_id, date, value) do
    if get_habit!(user_id, habit_id) do
      %HabitEntry{}
      |> HabitEntry.changeset(%{
        habit_id: habit_id,
        date: date,
        value: value
      })
      |> Repo.insert!(on_conflict: :replace_all, conflict_target: [:habit_id, :date])
    else
      raise "Could not find habit"
    end
  end

  def get_habit_entries!(user_id, habit_id, date_range) do
    if get_habit!(user_id, habit_id) do
      Repo.all(
        from entry in HabitEntry,
        select: entry,
        where: entry.habit_id == ^habit_id
            and entry.date >= ^date_range.first
            and entry.date <= ^date_range.last
      )
    else
      raise "Could not find habit"
    end
  end

  def get_shared_habit_entries!(share_id, habit_id, date_range) do
    if not is_nil(share_id) do
      Repo.all(
        from entry in HabitEntry,
        select: entry,
        join: habit in Habit,
        join: sheet in Sheet,
        where: entry.habit_id == ^habit_id
            and entry.date >= ^date_range.first
            and entry.date <= ^date_range.last
            and sheet.share_id == ^share_id
      )
    else
      raise "Could not find habit"
    end
  end

  def get_habit_entry_value_map(user_id, habit_id, date_range) do
    Map.new(get_habit_entries!(user_id, habit_id, date_range), fn entry -> { entry.date, entry } end)
  end

  def get_shared_habit_entry_value_map(share_id, habit_id, date_range) do
    Map.new(get_shared_habit_entries!(share_id, habit_id, date_range), fn entry -> { entry.date, entry } end)
  end

  def list_habits_for_shared_sheet(share_id) do
    if not is_nil(share_id) do
      Repo.all(
        from habit in Habit,
        select: habit,
        join: sheet in Sheet,
        where: sheet.share_id == ^share_id and is_nil(habit.archived_at)
      )
    else
      raise "Could not find shared sheet"
    end
  end

  def get_week_range(date) do
    Date.range(
      Date.beginning_of_week(date),
      Date.end_of_week(date)
    )
  end

  def get_habit_entries_for_date(user_id, sheet_id, date) do
    Repo.all(
      from habit in Habit,
      join: entry in HabitEntry,
      on: entry.habit_id == habit.id,
      select: %{habit | entry: entry},
      where: habit.sheet_id == ^sheet_id
         and habit.user_id == ^user_id
         and entry.date == ^date
    )
  end

  def delete_sheets_for_user(user_id) do
    Repo.delete_all(
      from sheet in Sheet,
      where: sheet.user_id == ^user_id
    )
  end
end
