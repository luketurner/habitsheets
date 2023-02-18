defmodule Habitsheet.Repo.Migrations.AddEmailColumnsToDailyReviews do
  use Ecto.Migration

  def change do
    alter table(:daily_reviews) do
      add :email_status, :string, null: false
      add :email_failure_count, :integer, null: false
    end

    create index(:daily_reviews, [:email_status, :email_failure_count])
  end
end
