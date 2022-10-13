defmodule Safira.Repo.Migrations.AddAdminToManager do
  use Ecto.Migration

  def change do
    alter table(:managers) do
      add :is_admin, :boolean, default: false, null: false
    end
  end
end
