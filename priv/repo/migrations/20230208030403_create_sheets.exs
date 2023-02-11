defmodule Habitsheet.Repo.Migrations.CreateSheets do
  use Ecto.Migration

  def change do
    create table(:sheets, primary_key: false) do
      add :id, :binary, primary_key: true
      add :title, :string

      timestamps()
    end
  end
end
