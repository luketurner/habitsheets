defmodule Habitsheet.Repo.Migrations.CreateSheets do
  use Ecto.Migration

  def change do
    create table(:sheets) do
      add :title, :string

      timestamps()
    end
  end
end
