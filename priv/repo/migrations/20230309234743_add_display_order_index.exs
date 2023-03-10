defmodule Habitsheet.Repo.Migrations.AddDisplayOrderIndex do
  use Ecto.Migration

  def change do
    create index(:habits, [:user_id, :display_order])
  end
end
