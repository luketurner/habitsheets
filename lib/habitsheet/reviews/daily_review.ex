defmodule Habitsheet.Reviews.DailyReview do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Users.User
  alias Habitsheet.Sheets.Sheet
  alias Habitsheet.Reviews.DailyReviewEmail

  schema "daily_reviews" do
    field :date, :date
    field :notes, :string
    field :status, Ecto.Enum, values: [:not_started, :started, :finished], default: :not_started
    field :email_status, Ecto.Enum, values: [:pending, :failed, :sent, :skipped], default: :pending
    field :email_failure_count, :integer, default: 0
    field :email_attempt_count, :integer, default: 0

    belongs_to :user, User
    belongs_to :sheet, Sheet, type: :binary_id
    has_many :email, DailyReviewEmail

    timestamps()
  end

  @doc false
  def changeset(daily_review, attrs) do
    daily_review
    |> cast(attrs, [:date, :notes, :status, :email_status, :email_failure_count, :email_attempt_count, :user_id, :sheet_id])
    |> validate_required([:date, :status, :email_status, :email_failure_count, :email_attempt_count, :user_id, :sheet_id])
  end
end
