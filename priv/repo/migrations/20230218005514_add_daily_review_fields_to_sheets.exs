defmodule Habitsheet.Repo.Migrations.AddDailyReviewsEnabledToSheets do
  use Ecto.Migration

  def change do
    alter table(:sheets) do
      add :daily_review_email_enabled, :boolean
      add :daily_review_email_time, :time
    end
  end
end
