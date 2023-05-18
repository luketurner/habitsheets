defmodule Habitsheet.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @behaviour Bodyguard.Schema

  alias Habitsheet.Habits.HabitEntry
  alias Habitsheet.Habits.RecurringInterval
  alias Habitsheet.Habits.AdditionalDataSpec
  alias Habitsheet.Habits.Notes
  alias Habitsheet.Habits.HabitTrigger
  alias Habitsheet.Users.User

  @habit_types [:action, :attitude]
  @habit_senses [:positive, :negative]

  schema "habits" do
    field :name, :string
    field :display_order, :integer
    field :archived_at, :naive_datetime
    field :important, :boolean
    field :type, Ecto.Enum, values: @habit_types
    field :sense, Ecto.Enum, values: @habit_senses
    field :expiration, :integer

    embeds_many :additional_data_spec, AdditionalDataSpec, on_replace: :delete
    embeds_many :recurrence, RecurringInterval, on_replace: :delete
    embeds_many :triggers, HabitTrigger, on_replace: :delete
    embeds_one :notes, Notes, on_replace: :delete

    belongs_to :user, User
    has_many :entry, HabitEntry

    timestamps()
  end

  def scope(query, %User{id: user_id}, _) do
    from habit in query, where: habit.user_id == ^user_id
  end

  @doc false
  def create_changeset(habit, attrs) do
    habit
    |> cast(attrs, [
      :name,
      :display_order,
      :archived_at,
      :important,
      :type,
      :sense,
      :expiration,
      :user_id
    ])
    |> cast_embed(:additional_data_spec)
    |> cast_embed(:recurrence)
    |> cast_embed(:notes)
    |> cast_embed(:triggers)
    |> validate_required([:name, :user_id])
  end

  def update_changeset(habit, attrs) do
    habit
    |> cast(attrs, [
      :name,
      :display_order,
      :archived_at,
      :important,
      :type,
      :sense,
      :expiration
    ])
    |> cast_embed(:additional_data_spec)
    |> cast_embed(:recurrence)
    |> cast_embed(:notes)
    |> cast_embed(:triggers)
  end

  def habit_types(), do: @habit_types
  def habit_senses(), do: @habit_senses

  @doc """
  Returns true if the habit recurs on a given day. Should always return true if no recurrences are defined.

  # Examples

      iex> Habit.recurs_on(%Habit{recurrence: []}, ~D[2023-01-01])
      true

      iex> Habit.recurs_on(%Habit{recurrence: nil}, ~D[2023-01-01])
      true

      iex> Habit.recurs_on(%Habit{recurrence: [%RecurringInterval{type: :weekly, every: 1, start: ~D[2023-01-01]}]}, ~D[2023-01-01])
      true

      iex> Habit.recurs_on(%Habit{recurrence: [%RecurringInterval{type: :weekly, every: 1, start: ~D[2023-01-01]}]}, ~D[2023-01-02])
      false

      iex> Habit.recurs_on(%Habit{recurrence: [%RecurringInterval{type: :weekly, every: 1, start: ~D[2023-01-01]}]}, ~D[2023-01-08])
      true
  """
  def recurs_on(%__MODULE__{} = habit, %Date{} = date) do
    recurrence = Map.get(habit, :recurrence, [])

    is_nil(recurrence) or Enum.empty?(recurrence) or
      Enum.any?(recurrence, &RecurringInterval.recurs_on(&1, date))
  end

  @doc """
  Returns true if the habit would be expired, given the previous date the habit was performed
  and the current date.

  # Examples

      iex> Habit.expired(%Habit{expiration: 2}, ~D[2022-01-01], ~D[2022-01-04])
      true

      iex> Habit.expired(%Habit{expiration: 2}, ~D[2022-01-01], ~D[2022-01-03])
      true

      iex> Habit.expired(%Habit{expiration: 2}, ~D[2022-01-01], ~D[2022-01-02])
      false

      iex> Habit.expired(%Habit{expiration: 1}, ~D[2022-01-01], ~D[2022-01-02])
      true

      iex> Habit.expired(%Habit{}, ~D[2022-01-01], ~D[2022-01-02])
      false
  """
  def expired(
        %__MODULE__{} = habit,
        %Date{} = last_habit_date,
        %Date{} = check_date
      ) do
    Date.diff(check_date, last_habit_date) >= Map.get(habit, :expiration, 1)
  end
end
