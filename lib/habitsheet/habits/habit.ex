defmodule Habitsheet.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @behaviour Bodyguard.Schema

  alias Habitsheet.Habits.HabitEntry
  alias Habitsheet.Users.User

  @color_choices [
    :primary,
    :secondary,
    :accent,
    :neutral,
    :base,
    :info,
    :success,
    :warning,
    :error
  ]

  schema "habits" do
    field :name, :string
    field :display_order, :integer
    field :archived_at, :naive_datetime

    field :display_color, Ecto.Enum,
      values: @color_choices,
      default: :primary

    # TODO use subschema
    field :additional_data_spec, :map

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
    |> cast(attrs, [:name, :display_order, :archived_at, :additional_data_spec, :user_id])
    |> validate_required([:name, :user_id])
  end

  def update_changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :display_order, :archived_at, :additional_data_spec])
  end

  def color_choices(), do: @color_choices
end
