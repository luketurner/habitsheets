defmodule Habitsheet.Repo.Migrations.CreateAgendas do
  use Ecto.Migration

  def change do
    create table(:agendas) do
      add :date, :date, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:agendas, [:date, :user_id])

    create table(:agendas_tasks) do
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :agenda_id, references(:agendas, on_delete: :delete_all), null: false
    end

    create unique_index(:agendas_tasks, [:agenda_id, :task_id])
  end
end
