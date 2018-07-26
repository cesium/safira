defmodule Safira.Repo.Migrations.CreateRedeems do
  use Ecto.Migration

  def change do
    create table(:redeems) do

      timestamps()
    end

  end
end
