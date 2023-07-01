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
    |> validate_required([:format])
  end

  def render(%__MODULE__{format: :md, content: content}) when is_nil(content), do: ""

  def render(%__MODULE__{format: :md, content: content}) do
    case Earmark.as_html(content, compact_output: true, postprocessor: fn node ->
      # We want to only allow certain nodes to render. Everything else gets replaced with an empty string.
      # This is done so we don't have to worry about rendering arbitrary HTML the user may have included.
      case node do
        {"p", _, _, _} -> node
        {"a", _, _, _} -> node
        {"em", _, _, _} -> node
        {"strong", _, _, _} -> node
        {"code", _, _, _} -> node
        {"ul", _, _, _} -> node
        {"ol", _, _, _} -> node
        {"li", _, _, _} -> node
        {"table", _, _, _} -> node
        {"thead", _, _, _} -> node
        {"tbody", _, _, _} -> node
        {"tr", _, _, _} -> node
        {"td", _, _, _} -> node
        {"th", _, _, _} -> node
        v when is_binary(v) -> node
        _ -> {:replace, ""}
      end
    end) do
      {:ok, html, _} -> html
      _ -> "Error rendering note"
    end
  end

  def render(_), do: ""
end
