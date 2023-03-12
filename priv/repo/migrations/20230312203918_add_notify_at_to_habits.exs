defmodule Habitsheet.Repo.Migrations.AddNotifyAtToHabits do
  use Ecto.Migration

  def change do
    alter table(:habits) do
      add :notify_at, :jsonb
    end
  end
end
