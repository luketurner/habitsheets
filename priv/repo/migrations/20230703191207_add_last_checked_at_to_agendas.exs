defmodule Habitsheet.Repo.Migrations.AddLastCheckedAtToAgendas do
  use Ecto.Migration

  def change do
    alter table(:agendas) do
      add :last_checked_at, :naive_datetime
    end
  end
end
