defmodule Habitsheet.Repo.Migrations.AddUserToSheets do
  use Ecto.Migration

  def change do
    alter table(:sheets) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
