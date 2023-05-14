defmodule Habitsheet.Sheet do
  alias Habitsheet.Users.User
  alias Habitsheet.Habits
  alias Habitsheet.Habits.Habit
  alias Habitsheet.Habits.HabitEntry
  alias Habitsheet.Reviews

  alias Ecto.Changeset

  defstruct [
    :user,
    :entries,
    :habits,
    :dates,
    :reviews,
    :entry_index_date_first,
    :entry_index_habit_first,
    :habit_index,
    :review_index
  ]

  def new(%User{} = user, %Date.Range{} = dates) do
    sheet = %__MODULE__{
      user: user,
      dates: dates
    }

    with(
      {:ok, sheet} <- load_habits(sheet),
      {:ok, sheet} <- load_entries(sheet),
      {:ok, sheet} <- load_reviews(sheet)
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

  def get_habits_for_date(%__MODULE__{} = sheet, %Date{} = date) do
    # Eventually, this should omit expired or recurring habits that aren't applicable for the date
    sheet.habits
  end
end
