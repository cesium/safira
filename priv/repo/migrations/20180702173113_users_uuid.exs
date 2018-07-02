defmodule Safira.Repo.Migrations.UsersUuid do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :uuid, :string
    end

    create unique_index(:users, [:uuid])
  end
end
