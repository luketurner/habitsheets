defmodule Habitsheet.Repo.Migrations.CreateHabitStatistics do
  use Ecto.Migration

  def change do
    create table(:habit_statistics) do
      add :value_type, :string
      add :range, :string
      add :start, :date
      add :end, :date
      add :value_count, :integer
      add :value_sum, :integer
      add :value_mean, :float
      add :habit_id, references(:habits, on_delete: :delete_all)

      timestamps()
    end

    create index(:habit_statistics, [:habit_id])
    create index(:habit_statistics, [:habit_id, :range, :start])
  end
end
