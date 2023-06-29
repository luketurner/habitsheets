defmodule Habitsheet.Notes do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :format, Ecto.Enum, values: [:md], default: :md
    field :content, :string
  end

  def changeset(%__MODULE__{} = notes, attrs \\ %{}) do
    notes
    |> cast(attrs, [:format, :content])
    |> validate_required([:format, :content])
  end
end
