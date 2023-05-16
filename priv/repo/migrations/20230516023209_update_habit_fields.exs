defmodule Habitsheet.Repo.Migrations.UpdateHabitFields do
  use Ecto.Migration

  def change do
    alter table(:habits) do
      remove :notify_at, :jsonb
      remove :display_color, :string
      add :recurrence, :jsonb
      add :notes, :jsonb
      add :important, :boolean
      add :type, :string
      add :sense, :string
      add :expiration, :integer
      add :triggers, :jsonb
    end
  end
end
