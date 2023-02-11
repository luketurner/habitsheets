defmodule Habitsheet.Sheets.Sheet do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Sheets.Habit

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "sheets" do
    field :title, :string

    has_many :habit, Habit
    timestamps()
  end

  @doc false
  def changeset(sheet, attrs) do
    sheet
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
