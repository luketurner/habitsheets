defmodule Habitsheet.Repo.Migrations.AddArchivedAtToHabits do
  use Ecto.Migration

  def change do
    alter table(:habits) do
      add :archived_at, :naive_datetime
    end
  end
end
