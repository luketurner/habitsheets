defmodule Habitsheet.Reviews.DailyReview do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Users.User
  alias Habitsheet.Sheets.Sheet

  schema "daily_reviews" do
    field :date, :date
    field :notes, :string
    field :status, Ecto.Enum, values: [:started, :finished]

    belongs_to :user, User
    belongs_to :sheet, Sheet, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(daily_review, attrs) do
    daily_review
    |> cast(attrs, [:date, :status, :notes, :user_id, :sheet_id, :entries])
    |> validate_required([:date, :status, :user_id, :sheet_id])
  end
end
