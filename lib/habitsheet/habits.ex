defmodule Habitsheet.Habits do
  @moduledoc """
  The Habits context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Habitsheet.Repo

  alias Habitsheet.Habits.Habit
  alias Habitsheet.Habits.HabitEntry
  alias Habitsheet.Users.User

  @behaviour Bodyguard.Policy

  def authorize(:get_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok

  def authorize(:list_habits_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok
  def authorize(:list_habit_entries_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok
  def authorize(:delete_habits_for_user, %User{id: user_id}, %User{id: user_id}), do: :ok

  # Habits can only be edited by their owner
  def authorize(:update_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok
  def authorize(:delete_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok
  def authorize(:archive_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok
  def authorize(:unarchive_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok
  def authorize(:update_entry_for_habit, %User{id: user_id}, %Habit{user_id: user_id}), do: :ok

  # Any logged-in user can create a habit, but only for themselves
  def authorize(:create_habit, %User{id: user_id}, %Changeset{changes: %{user_id: user_id}}),
    do: :ok

  # Fallback policy
  def authorize(_, _, _), do: :error

  def get_habit(id) do
    case Repo.get(Habit, id) do
      nil -> {:error, :not_found}
      habit -> {:ok, habit}
    end
  end

  def get_habit_as(%User{} = current_user, id) do
    with(
      {:ok, habit} <- get_habit(id),
      :ok <- Bodyguard.permit(__MODULE__, :get_habit, current_user, habit)
    ) do
      {:ok, habit}
    end
  end

  def list_habits_for_user(%User{} = user) do
    {:ok,
     Repo.all(
       from habit in Habit,
         select: habit,
         where:
           habit.user_id == ^user.id and
             is_nil(habit.archived_at)
     )}
  end

  def list_habits_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(__MODULE__, :list_habits_for_user, current_user, user) do
      list_habits_for_user(user)
    end
  end

  def list_archived_habits_for_user(%User{} = user) do
    {:ok,
     Repo.all(
       from habit in Habit,
         select: habit,
         where:
           habit.user_id == ^user.id and
             not is_nil(habit.archived_at)
     )}
  end

  def list_archived_habits_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(__MODULE__, :list_habits_for_user, current_user, user) do
      list_archived_habits_for_user(user)
    end
  end

  def list_entries_for_user(%User{} = user, date_range) do
    {:ok,
     Repo.all(
       from entry in HabitEntry,
         join: habit in Habit,
         select: %{entry | habit: habit},
         where:
           habit.user_id == ^user.id and
             is_nil(habit.archived_at) and
             entry.date >= ^date_range.first and
             entry.date <= ^date_range.last
     )}
  end

  def list_entries_for_user_as(%User{} = current_user, %User{} = user, date_range) do
    with :ok <- Bodyguard.permit(__MODULE__, :list_habit_entries_for_user, current_user, user) do
      list_entries_for_user(user, date_range)
    end
  end

  def entry_map(habit_entries) do
    Map.new(
      Enum.map(habit_entries, fn entry ->
        {entry.habit_id, entry}
      end)
    )
  end

  def delete_habits_for_user(%User{id: user_id}) do
    {:ok,
     Repo.delete_all(
       from habit in Habit,
         where: habit.user_id == ^user_id
     )}
  end

  def delete_habits_for_user_as(%User{} = current_user, %User{} = user) do
    with :ok <- Bodyguard.permit(__MODULE__, :delete_habits_for_user, current_user, user) do
      delete_habits_for_user(user)
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
    with :ok <- Bodyguard.permit(__MODULE__, :create_habit, current_user, habit) do
      create_habit(habit)
    end
  end

  def update_habit(%Changeset{data: %Habit{}} = changeset) do
    Repo.update(changeset)
  end

  def update_habit_as(%User{} = current_user, %Changeset{data: %Habit{}} = changeset) do
    with :ok <- Bodyguard.permit(__MODULE__, :update_habit, current_user, changeset.data) do
      update_habit(changeset)
    end
  end

  def archive_habit(%Habit{} = habit) do
    update_habit(
      habit_update_changeset(habit, %{
        archived_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      })
    )
  end

  def archive_habit_as(%User{} = current_user, %Habit{} = habit) do
    with :ok <- Bodyguard.permit(__MODULE__, :archive_habit, current_user, habit) do
      archive_habit(habit)
    end
  end

  def unarchive_habit(%Habit{} = habit) do
    update_habit(
      habit_update_changeset(habit, %{
        archived_at: nil
      })
    )
  end

  def unarchive_habit_as(%User{} = current_user, %Habit{} = habit) do
    with :ok <- Bodyguard.permit(__MODULE__, :unarchive_habit, current_user, habit) do
      unarchive_habit(habit)
    end
  end

  # special override to delete entry
  def update_habit_entry_for_date(%Habit{} = habit, date, :delete) do
    {:ok,
     Repo.delete_all(
       from entry in HabitEntry,
         where:
           entry.habit_id == ^habit.id and
             entry.date == ^date
     )}
  end

  def update_habit_entry_for_date(%Habit{} = habit, date, additional_data) do
    %HabitEntry{}
    |> HabitEntry.create_changeset(%{
      habit_id: habit.id,
      date: date,
      additional_data: additional_data
    })
    |> Repo.insert(on_conflict: :replace_all, conflict_target: [:habit_id, :date])
  end

  def update_habit_entry_for_date_as(%User{} = current_user, %Habit{} = habit, date, value) do
    with :ok <- Bodyguard.permit(__MODULE__, :update_entry_for_habit, current_user, habit) do
      update_habit_entry_for_date(habit, date, value)
    end
  end
end
