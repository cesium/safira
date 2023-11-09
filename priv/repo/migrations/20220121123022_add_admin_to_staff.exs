defmodule Safira.Repo.Migrations.AddAdminToStaff do
  use Ecto.Migration

  def change do
    alter table(:staffs) do
      add :is_admin, :boolean, default: false, null: false
    end
  end
end
