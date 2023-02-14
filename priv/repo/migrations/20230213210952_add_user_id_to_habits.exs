defmodule Habitsheet.Repo.Migrations.AddUserIdToHabits do
  use Ecto.Migration

  def change do
    alter table(:habits) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
