defmodule Habitsheet.Repo.Migrations.AddOverallTaskLimitToAgendas do
  use Ecto.Migration

  def change do
    alter table(:agendas) do
      add :overall_task_limit, :integer
    end
  end
end
