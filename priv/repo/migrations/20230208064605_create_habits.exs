defmodule Habitsheet.Repo.Migrations.CreateHabits do
  use Ecto.Migration

  def change do
    create table(:habits) do
      add :name, :string
      add :sheet_id, references(:sheets, on_delete: :delete_all, type: :binary), null: false

      timestamps()
    end

    create index(:habits, [:sheet_id])
  end
end
