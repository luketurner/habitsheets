defmodule Habitsheet.Habits.AdditionalDataSpec do
  use Ecto.Type

  defstruct data_type: nil, default_value: nil, label: nil

  # public API

  def new(data_type, label, opts \\ []) do
    %__MODULE__{data_type: data_type, label: label, default_value: opts[:default_value]}
  end

  ## Ecto.Type callbacks

  def type, do: :map

  def cast(%__MODULE__{} = data), do: {:ok, data}

  def cast(_), do: {:error, :invalid_additional_data_spec}

  def load(%{"data_type" => data_type, "label" => label, "default_value" => default_value}) do
    {:ok, new(data_type, label, default_value: default_value)}
  end

  def dump(%__MODULE__{} = data), do: {:ok, Map.from_struct(data)}
  def dump(_), do: :error
end
