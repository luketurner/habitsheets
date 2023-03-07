defmodule Habitsheet.Repo.Migrations.AddDailyReviewEmailConfigToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :daily_review_email_enabled, :boolean
      add :daily_review_email_time, :time
    end
  end
end
