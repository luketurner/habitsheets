defmodule Habitsheet.Habits.RecurringInterval do
  alias Habitsheet.DateHelpers
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :type, Ecto.Enum, values: [:weekly]
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

        # :monthly ->
        #   date.day == start.day and
        #     rem((date.month - start.month) * 12 + (date.month - start.month), every) == 0
    end
  end

  @"""
  Returns a short string like "every Mon", suitable for putting in a button/tag/badge.
  """
  def to_display_string(%__MODULE__{every: every, type: type, start: start}) do
    case type do
      :weekly ->
        if(every == 1,
          do: "every #{DateHelpers.day_of_week(start)}",
          else: "every #{every} #{DateHelpers.day_of_week(start)}"
        )
    end
  end

  @"""
  Returns a sentence-form description of the interval, like "Every third Monday starting on 2022-01-01",
  suitable for putting in alt-text or an editing page.
  """
  def to_display_sentence(%__MODULE__{start: start, every: every, type: type}) do
    case type do
      :weekly ->
        if(every == 1,
          do:
            "Every #{DateHelpers.day_of_week(start)} starting on #{DateHelpers.readable_date(start)}",
          else:
            "Every #{every} #{DateHelpers.day_of_week(start)} starting on #{DateHelpers.readable_date(start)}"
        )
    end
  end
end
