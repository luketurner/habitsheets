defmodule Habitsheet.Habits.RecurringInterval do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :type, Ecto.Enum, values: [:weekly, :monthly]
    field :every, :integer
    field :start, :date
  end

  def changeset(%__MODULE__{} = interval, attrs \\ %{}) do
    interval
    |> cast(attrs, [:type, :every, :start])
    |> validate_required([:type, :every, :start])
  end

  def recurs_on(%__MODULE__{start: start, every: every, type: type}, %Date{} = date) do
    case type do
      :weekly ->
        rem(Date.diff(start, date), 7 * every) == 0

      :monthly ->
        date.day == start.day and
          rem((date.month - start.month) * 12 + (date.month - start.month), every) == 0
    end
  end
end
