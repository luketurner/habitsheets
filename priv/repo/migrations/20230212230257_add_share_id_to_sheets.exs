defmodule Habitsheet.Repo.Migrations.AddShareIdToSheets do
  use Ecto.Migration

  def change do
    alter table(:sheets) do
      add :share_id, :binary
    end

    create index(:sheets, [:share_id])
  end
end
