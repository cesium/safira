defmodule Safira.Repo.Migrations.CreateAdminUsers do
  use Ecto.Migration

  def change do
    create table(:admin_users) do
      add :email, :string, null: false
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:admin_users, [:email])
  end
end
