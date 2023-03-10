defmodule Habitsheet.Repo.Migrations.AddColorToHabits do
  use Ecto.Migration

  def change do
    alter table(:habits) do
      add :display_color, :string
    end
  end
end
