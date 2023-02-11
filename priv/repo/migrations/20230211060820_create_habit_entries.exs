defmodule Habitsheet.Repo.Migrations.CreateHabitEntries do
  use Ecto.Migration

  def change do
    create table(:habit_entries) do
      add :date, :date, null: false
      add :value, :integer, null: false
      add :habit_id, references(:habits, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:habit_entries, [:habit_id, :date], unique: true)
  end
end
