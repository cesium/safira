defmodule Safira.Repo.Migrations.CreateStaff do
  use Ecto.Migration

  def change do
    create table(:managers) do
      add :active, :boolean, default: true
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
