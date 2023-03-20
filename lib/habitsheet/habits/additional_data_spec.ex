defmodule Habitsheet.Habits.AdditionalDataSpec do
  use Ecto.Schema
  import Ecto.Changeset

  @data_types [:count, :measurement, :duration, :text]

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  embedded_schema do
    field :data_type, Ecto.Enum, values: @data_types, default: :count
    field :label, :string
    field :default_value, :binary
    field :display_order, :integer
  end

  def data_types, do: @data_types

  def changeset(%__MODULE__{} = spec, attrs \\ %{}) do
    spec
    |> cast(attrs, [:id, :data_type, :label, :default_value])
    |> validate_required([:id, :data_type, :label])
  end
end
