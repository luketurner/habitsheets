defmodule Habitsheet.Reviews.DailyReviewEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Reviews.DailyReview

  schema "daily_review_emails" do
    field :email, :string
    field :attempt, :integer
    field :status, Ecto.Enum, values: [:success, :failure]
    field :trigger, Ecto.Enum, values: [:fill_review, :user]
    field :error_text, :string

    belongs_to :daily_review, DailyReview

    timestamps()
  end

  @doc false
  def changeset(daily_review_email, attrs) do
    daily_review_email
    |> cast(attrs, [:email, :attempt, :status, :trigger, :daily_review_id])
    |> validate_required([:email, :attempt, :status, :trigger, :daily_review_id])
  end
end
