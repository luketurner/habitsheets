defmodule Habitsheet.Repo.Migrations.AddUserToSheets do
  use Ecto.Migration

  def change do
    alter table(:sheets) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:sheets_user_id, [:user_id])
  end
end
