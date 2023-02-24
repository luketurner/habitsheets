defmodule Habitsheet.Sheets do
  @moduledoc """
  The Sheets context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Habitsheet.Repo

  alias Habitsheet.Sheets.Sheet
  alias Habitsheet.Sheets.Habit
  alias Habitsheet.Sheets.HabitEntry
  alias Habitsheet.Users.User

  alias __MODULE__

  @behaviour Bodyguard.Policy

  # TODO -- should this check user confirmation? I'm thinking no

  # Users can only list their own sheets
  def authorize(:list_sheets_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok

  # Users can only delete all sheets for their own user
  def authorize(:delete_sheets_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok

  # Users can get their own sheets and related sub-resources
  # TODO make this more DRY? Or does it matter?
  def authorize(:get_sheet, %User{id: user_id}, %Sheet{user_id: user_id}), do: :ok
  def authorize(:list_habits_for_sheet, %User{id: user_id}, %Sheet{user_id: user_id}), do: :ok
  def authorize(:list_habit_entries_for_sheet, %User{id: user_id}, %Sheet{user_id: user_id}), do: :ok

  # Anyone can get a sheet (or related habits/entries) with a share ID
  def authorize(:get_sheet, _user, %Sheet{share_id: share_id}), do: !is_nil(share_id)
  def authorize(:list_habits_for_sheet, _user, %Sheet{share_id: share_id}), do: !is_nil(share_id)
  def authorize(:list_habit_entries_for_sheet, _user, %Sheet{share_id: share_id}), do: !is_nil(share_id)

  # Only the owner can update/delete a sheet
  def authorize(:update_sheet, %User{id: user_id}, %Sheet{user_id: user_id}), do: :ok
  def authorize(:delete_sheet, %User{id: user_id}, %Sheet{user_id: user_id}), do: :ok

  # Some special types of updates, because they change sheet visibility
  # is there any point to handling these separately from :update_sheet?
  def authorize(:share_sheet, %User{id: user_id}, %Sheet{user_id: user_id}), do: :ok
  def authorize(:unshare_sheet, %User{id: user_id}, %Sheet{user_id: user_id}), do: :ok

  # Any logged-in user can create a sheet, but only for themselves
  def authorize(:create_sheet, %User{id: user_id}, %Changeset{changes: %{user_id: user_id}}), do: :ok

  # Habits can only be edited by their owner
  def authorize(:update_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok
  def authorize(:delete_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok
  def authorize(:archive_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok
  def authorize(:update_entry_for_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok

  # Any logged-in user can create a habit, but only for themselves
  def authorize(:create_habit, %User{id: user_id}, %Changeset{changes: %{user_id: user_id}}), do: :ok


  # Fallback policy
  def authorize(_, _, _), do: :error


  def list_sheets_for_user(%User{} = user) do
    {:ok,
     Sheet
     |> Bodyguard.scope(user)
     |> Repo.all}
  end

  def list_sheets_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(Sheets, :list_sheets_for_user, current_user, user) do
      list_sheets_for_user(user)
    end
  end

  def delete_sheet(%Sheet{} = sheet) do
    Repo.delete(sheet)
  end

  def delete_sheet_as(%User{} = current_user, %Sheet{} = sheet) do
    with :ok <- Bodyguard.permit(Sheets, :delete_sheet, current_user, sheet) do
      delete_sheet(sheet)
    end
  end

  def get_sheet(sheet_id) do
    if sheet = Repo.get(Sheet, sheet_id) do
      {:ok, sheet}
    else
      {:error, "sheet not found"}
    end
  end

  def get_sheet_as(current_user, sheet_id)
  do
    with(
      {:ok, sheet} <- get_sheet(sheet_id),
      :ok <- Bodyguard.permit(Sheets, :get_sheet, current_user, sheet)
    ) do
      {:ok, sheet}
    else
      # return same error for missing sheet vs. unauthorized sheet
      {:error, :unauthorized} -> {:error, "sheet not found"}
      error -> error
    end
  end

  def get_sheet_by_share_id(share_id) do
    if is_nil(share_id) do
      {:error, "shared sheet not found"}
    else
      if sheet = Repo.get_by(Sheet, share_id: share_id) do
        {:ok, sheet}
      else
        {:error, "shared sheet not found"}
      end
    end
  end

  def get_sheet_by_share_id_as(current_user, share_id) do
    with {:ok, sheet} <- get_sheet_by_share_id(share_id),
         :ok <- Bodyguard.permit(Sheets, :get_sheet, current_user, sheet) do
      {:ok, sheet}
    else
      {:error, :unauthorized} -> {:error, "shared sheet not found"}
      error -> error
    end
  end

  def create_sheet(%Changeset{data: %Sheet{}} = sheet) do
    Repo.insert(sheet)
  end

  def create_sheet_as(%User{} = current_user, %Changeset{data: %Sheet{}} = sheet) do
    with :ok <- Bodyguard.permit(Sheets, :create_sheet, current_user, sheet) do
      create_sheet(sheet)
    end
  end

  def update_sheet(%Changeset{data: %Sheet{}} = sheet) do
    Repo.update(sheet)
  end

  def update_sheet_as(%User{} = current_user, %Changeset{data: %Sheet{}} = sheet) do
    with :ok <- Bodyguard.permit(Sheets, :update_sheet, current_user, sheet) do
      update_sheet(sheet)
    end
  end

  def sheet_update_changeset(%Sheet{} = sheet, attrs \\ %{}) do
    Sheet.update_changeset(sheet, attrs)
  end

  def sheet_create_changeset(%Sheet{} = sheet, attrs \\ %{}) do
    Sheet.create_changeset(sheet, attrs)
  end

  def list_habits_for_sheet(%Sheet{} = sheet) do
    {:ok, Repo.all(
      from habit in Habit,
      select: habit,
      where:
        habit.sheet_id == ^sheet.id
        and is_nil(habit.archived_at)
    )}
  end

  def list_habits_for_sheet_as(current_user, %Sheet{} = sheet) do
    with :ok <- Bodyguard.permit(Sheets, :list_habits_for_sheet, current_user, sheet) do
      list_habits_for_sheet(sheet)
    end
  end

  def list_habit_entries_for_sheet(%Sheet{} = sheet, date_range) do
    {:ok, Repo.all(
      from entry in HabitEntry,
      join: habit in Habit,
      select: %{entry | habit: habit},
      where:
        habit.sheet_id == ^sheet.id
        and is_nil(habit.archived_at)
        and entry.date >= ^date_range.first
        and entry.date <= ^date_range.last
    )}
  end

  def list_habit_entries_for_sheet_as(current_user, %Sheet{} = sheet, date_range) do
    with :ok <- Bodyguard.permit(Sheets, :list_habit_entries_for_sheet, current_user, sheet) do
      list_habit_entries_for_sheet(sheet, date_range)
    end
  end

  def habit_entry_map(habits, date_range, habit_entries) do
    entry_map = Map.new(Enum.map(habit_entries, fn entry ->
      {{entry.habit_id, entry.date}, entry}
    end))
    Map.new(Enum.map(habits, fn habit ->
      {habit.id, Map.new(Enum.map(date_range, fn date ->
        {date, Map.get(entry_map, {habit.id, date})}
      end))}
    end))
  end

  def delete_sheets_for_user(%User{id: user_id}) do
    {:ok, Repo.delete_all(
      from sheet in Sheet,
      where: sheet.user_id == ^user_id
    )}
  end

  def delete_sheets_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(Sheets, :delete_sheets_for_user, current_user, user) do
      delete_sheets_for_user(user)
    end
  end

  def share_sheet(%Sheet{} = sheet) do
    update_sheet(sheet_update_changeset(sheet, %{
      share_id: Ecto.UUID.generate()
    }))
  end

  def share_sheet_as(%User{} = current_user, %Sheet{} = sheet) do
    with :ok <- Bodyguard.permit(Sheets, :share_sheet, current_user, sheet) do
      share_sheet(sheet)
    end
  end

  def unshare_sheet(%Sheet{} = sheet) do
    update_sheet(sheet_update_changeset(sheet, %{
      share_id: nil
    }))
  end

  def unshare_sheet_as(%User{} = current_user, %Sheet{} = sheet) do
    with :ok <- Bodyguard.permit(Sheets, :unshare_sheet, current_user, sheet) do
      unshare_sheet(sheet)
    end
  end

  def habit_update_changeset(%Habit{} = habit, attrs \\ %{}) do
    Habit.update_changeset(habit, attrs)
  end

  def habit_create_changeset(%Habit{} = habit, attrs \\ %{}) do
    Habit.create_changeset(habit, attrs)
  end

  def create_habit(%Changeset{data: %Habit{}} = habit) do
    Repo.insert(habit)
  end

  def create_habit_as(%User{} = current_user, %Changeset{data: %Habit{}} = habit) do
    with :ok <- Bodyguard.permit(Sheets, :create_habit, current_user, habit) do
      create_habit(habit)
    end
  end

  def update_habit(%Changeset{data: %Habit{}} = habit) do
    Repo.update(habit)
  end

  def update_habit_as(%User{} = current_user, %Changeset{data: %Habit{}} = habit) do
    with :ok <- Bodyguard.permit(Sheets, :update_habit, current_user, habit) do
      update_habit(habit)
    end
  end

  def archive_habit(%Habit{} = habit) do
    update_habit(habit_update_changeset(habit, %{
      archived_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    }))
  end

  def archive_habit_as(%User{} = current_user, %Habit{} = habit) do
    with :ok <- Bodyguard.permit(Sheets, :archive_habit, current_user, habit) do
      archive_habit(habit)
    end
  end

  def update_habit_entry_for_date(%Habit{} = habit, date, value) do
    %HabitEntry{}
    |> HabitEntry.create_changeset(%{
      habit_id: habit.id,
      date: date,
      value: value
    })
    |> Repo.insert(on_conflict: :replace_all, conflict_target: [:habit_id, :date])
  end

  def update_habit_entry_for_date_as(%User{} = current_user, %Habit{} = habit, date, value) do
    with :ok <- Bodyguard.permit(Sheets, :update_entry_for_habit, current_user, habit) do
      update_habit_entry_for_date(habit, date, value)
    end
  end
end
