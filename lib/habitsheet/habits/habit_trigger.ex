defmodule Habitsheet.Habits.HabitTrigger do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    # TODO
  end

  def changeset(%__MODULE__{} = trigger, attrs \\ %{}) do
    trigger
    |> cast(attrs, [])
    |> validate_required([])
  end
end
