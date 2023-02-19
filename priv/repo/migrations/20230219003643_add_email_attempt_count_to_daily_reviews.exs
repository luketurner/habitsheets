defmodule Habitsheet.Repo.Migrations.AddEmailAttemptCountToDailyReviews do
  use Ecto.Migration

  def change do
    alter table(:daily_reviews) do
      add :email_attempt_count, :integer, null: false
    end
  end
end
