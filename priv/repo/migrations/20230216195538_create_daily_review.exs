defmodule Habitsheet.Repo.Migrations.CreateDailyReview do
  use Ecto.Migration

  def change do
    create table(:daily_reviews) do
      add :date, :date, null: false
      add :status, :string, null: false
      add :notes, :text
      add :sheet_id, references(:sheets, on_delete: :delete_all, type: :binary), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:daily_reviews, [:user_id, :sheet_id, :date])

    create index(:daily_reviews, [:date])
    create index(:daily_reviews, [:sheet_id])
    create index(:daily_reviews, [:user_id])
  end
end
