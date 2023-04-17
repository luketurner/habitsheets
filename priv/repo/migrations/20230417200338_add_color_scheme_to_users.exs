defmodule Habitsheet.Repo.Migrations.AddColorSchemeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :color_scheme, :string, default: "browser"
    end
  end
end
