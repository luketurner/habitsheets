defmodule Habitsheet.Sheets.Sheet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Habitsheet.Sheets.Habit
  alias Habitsheet.Users.User

  @behaviour Bodyguard.Schema

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

  def scope(query, %User{id: user_id}, _) do
    from sheet in query, where: sheet.user_id == ^user_id
  end

  def create_changeset(sheet, attrs) do
    sheet
    |> cast(attrs, [:title, :user_id, :share_id, :daily_review_email_enabled, :daily_review_email_time])
    |> validate_required([:title, :user_id])
  end

  def update_changeset(sheet, attrs) do
    sheet
    |> cast(attrs, [:title, :share_id, :daily_review_email_enabled, :daily_review_email_time])
  end
end
