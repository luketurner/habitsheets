defmodule Habitsheet.Habits.RecurringInterval do
  use Ecto.Schema
  import Ecto.Changeset

  @zero_time ~N[2000-01-01 00:00:00]

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  embedded_schema do
    field :start, :naive_datetime, default: @zero_time
    field :interval, :naive_datetime, default: @zero_time
  end

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:id, :start, :interval])
    |> validate_required([:id, :start, :interval])
  end
end
