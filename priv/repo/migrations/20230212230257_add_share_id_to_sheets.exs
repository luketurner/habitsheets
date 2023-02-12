defmodule Habitsheet.Repo.Migrations.AddShareIdToSheets do
  use Ecto.Migration

  def change do
    alter table(:sheets) do
      add :share_id, :binary
    end

    create index(:sheets_share_id, [:share_id])
  end
end
