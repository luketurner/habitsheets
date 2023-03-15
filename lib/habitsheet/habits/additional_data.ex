defmodule Habitsheet.Habits.AdditionalData do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Habits.AdditionalDataSpec

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  embedded_schema do
    field :data_type, Ecto.Enum, values: AdditionalDataSpec.data_types()
    field :value, :binary
  end

  def changeset(%__MODULE__{} = data, attrs \\ %{}) do
    data
    |> cast(attrs, [:id, :data_type, :value])
    |> validate_required([:id, :data_type, :value])
  end
end
