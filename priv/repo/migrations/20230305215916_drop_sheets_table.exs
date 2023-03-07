defmodule Habitsheet.Repo.Migrations.DropSheetsTable do
  use Ecto.Migration

  def change do
    # TODO -- is this needed, or automatic?
    # drop index(:habits, [:sheet_id])
    # drop index(:daily_reviews, [:sheet_id])
    # alter unique_index(:daily_reviews, [:user_id, :sheet_id, :date])
    # drop index(:sheets, [:share_id])

    alter table(:habits) do
      remove :sheet_id, references(:sheets, on_delete: :delete_all, type: :binary), null: false
    end

    alter table(:daily_reviews) do
      remove :sheet_id, references(:sheets, on_delete: :delete_all, type: :binary), null: false
    end

    drop table(:sheets)
  end
end
