defmodule Habitsheet.Sheet do
  @moduledoc """
  A Sheet struct encapsulates all the preloaded data that's needed for viewing habits over a date range.
  Phoenix views, email handlers, etc. can create a sheet and then easily "ask the sheet" for whatever data is needed to render the UI / email / etc.
  
  # Examples (wip)
  
  sheet = Sheet.new(user, Date.range(~D[2022-01-01], ~D[2022-01-08]))
  Sheet.get_habits_for_date(sheet, ~D[2022-01-03])
  
  """
  alias Habitsheet.Users.User
  alias Habitsheet.Habits
  alias Habitsheet.Habits.Habit
  alias Habitsheet.Habits.HabitEntry
  alias Habitsheet.Reviews

  alias Ecto.Changeset

  @derive {Inspect, only: [:user, :dates]}

  defstruct [
    :user,
    :entries,
    :habits,
    :dates,
    :reviews,
    :entry_index_date_first,
    :entry_index_habit_first,
    :habit_index,
    :review_index,
    :habit_latest_entries
  ]

  def new(%User{} = user, %Date.Range{} = dates) do
    sheet = %__MODULE__{
      user: user,
      dates: dates
    }

    with(
      {:ok, sheet} <- load_habits(sheet),
      {:ok, sheet} <- load_entries(sheet),
      {:ok, sheet} <- load_reviews(sheet),
      {:ok, sheet} <- load_latest_entries(sheet)
    ) do
      {:ok, sheet}
    end
  end

  def new(%User{} = user, %Date{} = dates) do
    new(user, Date.range(dates, dates))
  end

  def load_habits(%__MODULE__{user: user} = sheet) do
    with {:ok, habits} <- Habits.list_habits_for_user_as(user, user) do
      {:ok,
       sheet
       |> Map.put(:habits, habits)
       |> Map.put(:habit_index, Map.new(habits, &{&1.id, &1}))}
    end
  end

  def load_entries(%__MODULE__{user: user, dates: dates} = sheet) do
    with {:ok, entries} <- Habits.list_entries_for_user_as(user, user, dates) do
      {:ok,
       sheet
       |> Map.put(:entries, entries)
       |> Map.put(:entry_index_date_first, Habits.entry_index_date_first(entries))
       |> Map.put(:entry_index_habit_first, Habits.entry_index_habit_first(entries))}
    end
  end

  def load_reviews(%__MODULE__{user: user, dates: dates} = sheet) do
    with {:ok, reviews} <- Reviews.list_reviews_for_dates_as(user, user, dates) do
      {:ok,
       sheet
       |> Map.put(:reviews, reviews)
       |> Map.put(:review_index, Map.new(reviews, &{&1.date, &1}))}
    end
  end

  def load_latest_entries(%__MODULE__{user: user, habits: habits, dates: dates} = sheet) do
    with {:ok, entries} <- Habits.get_latest_entry_dates_before_as(user, habits, dates.first) do
      {:ok, %{sheet | habit_latest_entries: entries}}
    end
  end

  def update_entry(
        %__MODULE__{user: user} = sheet,
        %Habit{} = habit,
        %Date{} = date,
        entry_params
      ) do
    changeset = HabitEntry.create_changeset(%HabitEntry{}, entry_params)
    entry = Changeset.apply_action!(changeset, :validate)

    case Habits.update_habit_entry_for_date_as(user, habit, date, entry.additional_data) do
      # TODO avoid reloading all entries
      {:ok, _entry} -> load_entries(sheet)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def toggle_entry(%__MODULE__{user: user} = sheet, %Habit{} = habit, %Date{} = date) do
    # TODO this whole function needs to be refactored!
    existing_entry = get_entry(sheet, habit, date)
    additional_data = if(existing_entry, do: :delete, else: [])

    case Habits.update_habit_entry_for_date_as(user, habit, date, additional_data) do
      {:ok, _entry} -> load_entries(sheet)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_entry(
        %__MODULE__{entry_index_date_first: entry_index} = _sheet,
        %Habit{} = habit,
        %Date{} = date
      ) do
    entry_index |> Map.get(date, %{}) |> Map.get(habit.id)
  end

  def get_entry(%__MODULE__{} = sheet, habit, %Date{} = date)
      when is_integer(habit) or is_binary(habit) do
    get_entry(sheet, get_habit(sheet, habit), date)
  end

  def get_habit(%__MODULE__{} = sheet, habit_id) when is_integer(habit_id) do
    sheet.habit_index |> Map.get(habit_id)
  end

  def get_habit(%__MODULE__{} = sheet, habit_id) when is_binary(habit_id) do
    get_habit(sheet, String.to_integer(habit_id))
  end

  def get_review(%__MODULE__{} = sheet, %Date{} = date) do
    sheet.review_index |> Map.get(date)
  end

  @doc """
  Returns the latest HabitEntry that occured before the given date. For example, if the date is 2022-01-10,
  and there was an entry on 2022-01-01, 2022-01-05, and 2022-01-11, the 2022-01-05 entry will be returned.
  This information is used to determine whether the habit is cooling down as of a given date.
  Note that the returned entry may be outside the date span of the Sheet.
  There may also be no returned entries if the habit has never had entries created for it.
  """
  def get_latest_entry_date_before(
        %__MODULE__{
          habit_latest_entries: latest_entries,
          entry_index_habit_first: entry_index
        },
        %Habit{} = habit,
        %Date{} = date
      ) do
    Map.get(entry_index, habit.id, %{})
    |> Map.values()
    |> Enum.map(fn entry -> entry.date end)
    |> Enum.filter(fn d -> d < date end)
    |> Enum.max(fn -> Map.get(latest_entries, habit.id) end)
  end

  def habit_recurs_on(%__MODULE__{}, %Habit{} = habit, %Date{} = date) do
    Habit.recurs_on(habit, date)
  end

  def habit_cooled_down_on(%__MODULE__{} = sheet, %Habit{} = habit, %Date{} = date) do
    Habit.cooled_down(habit, get_latest_entry_date_before(sheet, habit, date), date)
  end

  @doc """
  Returns whether or not a habit should be "shown" on a given date. Habits are generally
  always shown, unless they are cooling down, or they are recurring and the date isn't part
  of the recurring interval.
  """
  def habit_shown_on(%__MODULE__{} = sheet, %Habit{} = habit, %Date{} = date) do
    habit_recurs_on(sheet, habit, date) and habit_cooled_down_on(sheet, habit, date)
  end

  def get_habits_for_date(%__MODULE__{} = sheet, %Date{} = date) do
    sheet.habits
    |> Enum.filter(&habit_shown_on(sheet, &1, date))
  end
end
