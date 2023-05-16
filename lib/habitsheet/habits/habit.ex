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
end
