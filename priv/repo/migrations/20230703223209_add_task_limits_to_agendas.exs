defmodule Habitsheet.Repo.Migrations.AddTaskLimitsToAgendas do
  use Ecto.Migration

  def change do
    alter table(:agendas) do
      add :important_task_limit, :integer
      add :other_task_limit, :integer
    end
  end
end
