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
    |> validate_required([:id, :data_type])
  end

  def new!(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action!(:insert)
  end

  def zip_spec(additional_data, spec) do
    spec
    |> Enum.sort_by(& &1.display_order, :asc)
    |> Enum.map(fn spec ->
      {Enum.find(
         additional_data,
         new!(%{id: spec.id, data_type: spec.data_type}),
         &(&1.id == spec.id)
       ), spec}
    end)
  end

  def orphans(additional_data, spec) do
    additional_data
    |> Enum.reject(fn data -> Enum.find(spec, &(&1.id == data.id)) end)
  end
end
