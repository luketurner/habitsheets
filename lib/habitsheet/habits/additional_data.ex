defmodule Habitsheet.Habits.AdditionalData do
  use Ecto.Schema

  alias Habitsheet.Habits.AdditionalDataSpec

  embedded_schema do
    field :data_type, Ecto.Enum, values: AdditionalDataSpec.data_types()
    field :value, :binary
  end
end
