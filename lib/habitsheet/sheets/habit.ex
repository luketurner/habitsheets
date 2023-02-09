defmodule Habitsheet.Sheets.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Sheets.Sheet

  schema "habits" do
    field :name, :string

    belongs_to :sheet, Sheet
    timestamps()
  end

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :sheet_id])
    |> validate_required([:name, :sheet_id])
  end
end