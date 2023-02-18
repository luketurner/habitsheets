defmodule Habitsheet.Sheets.Sheet do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habitsheet.Sheets.Habit
  alias Habitsheet.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "sheets" do
    field :title, :string
    field :share_id, :binary_id
    field :daily_review_email_enabled, :boolean, default: false
    field :daily_review_email_time, :time, default: ~T[00:00:00]

    belongs_to :user, User
    has_many :habit, Habit

    timestamps()
  end

  @doc false
  def changeset(sheet, attrs) do
    sheet
    |> cast(attrs, [:title, :user_id, :share_id, :daily_review_email_enabled, :daily_review_email_time])
    |> validate_required([:title, :user_id])
  end
end
