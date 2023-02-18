defmodule Habitsheet.Repo.Migrations.CreateDailyReviewEmails do
  use Ecto.Migration

  def change do
    create table(:daily_review_emails) do
      add :attempt, :integer, null: false
      add :status, :string, null: false
      add :email, :string, null: false
      add :trigger, :string, null: false
      add :daily_review_id, references(:daily_reviews, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:daily_review_emails, [:daily_review_id])
  end
end
