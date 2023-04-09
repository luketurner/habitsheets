defmodule Habitsheet.Repo.Migrations.AddDateUserConstraintToDailyReview do
  use Ecto.Migration

  def change do
    create unique_index(:daily_reviews, [:user_id, :date])
  end
end
