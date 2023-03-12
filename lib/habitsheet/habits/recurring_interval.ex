defmodule Habitsheet.Habits.RecurringInterval do
  use Ecto.Type

  defstruct start: nil, interval: nil

  # public API

  def new(%DateTime{} = start, %DateTime{} = interval) do
    %__MODULE__{start: start, interval: interval}
  end

  ## Ecto.Type callbacks

  def type, do: :map

  # def cast(%{start: %DateTime{} = start, interval: %DateTime{} = interval}) do
  #   {:ok, new(start, interval)}
  # end

  def cast(%__MODULE__{} = interval), do: {:ok, interval}

  def cast(_), do: {:error, :invalid_recurring_interval}

  def load(%{"start" => start, "interval" => interval}) do
    {:ok, new(start, interval)}
  end

  def dump(%__MODULE__{} = data), do: {:ok, Map.from_struct(data)}
  def dump(_), do: :error
end
