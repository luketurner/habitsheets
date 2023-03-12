defmodule Habitsheet.Habits.AdditionalData do
  use Ecto.Type

  defstruct data_type: nil, value: nil

  @data_types [:numeric]

  # public API

  def new(data_type, value, _opts \\ []) when value in @data_types do
    %__MODULE__{data_type: data_type, value: value}
  end

  ## Ecto.Type callbacks

  def type, do: :map

  # def cast(%{data_type: data_type, value: value}) do
  #   {:ok, new(data_type, value)}
  # end

  def cast(%__MODULE__{} = data), do: {:ok, data}

  def cast(_), do: {:error, :invalid_additional_data}

  def load(%{"data_type" => data_type, "value" => value}) do
    {:ok, new(data_type, value)}
  end

  def dump(%__MODULE__{} = data), do: {:ok, Map.from_struct(data)}
  def dump(_), do: :error
end
