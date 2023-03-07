defmodule Habitsheet.Repo.Migrations.UpdateFieldsForHabitAndHabitEntry do
  use Ecto.Migration

  def change do
    alter table(:habit_entries) do
      remove :value, :integer, null: false
      add :additional_data, :jsonb
    end

    alter table(:habits) do
      add :display_order, :integer
      add :additional_data_spec, :jsonb
    end
  end
end
