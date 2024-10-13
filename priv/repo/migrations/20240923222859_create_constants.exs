defmodule Safira.Repo.Migrations.CreateConstants do
  use Ecto.Migration

  def change do
    create table(:constants, primary_key: false) do
      add :key, :string, primary_key: true
      add :value, :map

      timestamps(type: :utc_datetime)
    end
  end
end
