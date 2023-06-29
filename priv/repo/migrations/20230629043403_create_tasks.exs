defmodule Habitsheet.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string, null: false
      add :status, :string
      add :important, :boolean
      add :urgent, :boolean
      add :display_order, :integer
      add :archived_at, :naive_datetime
      add :completed_at, :naive_datetime

      add :notes, :jsonb

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:tasks, [:user_id, :display_order])
  end
end
