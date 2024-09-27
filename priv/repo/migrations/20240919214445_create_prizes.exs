defmodule Safira.Repo.Migrations.CreateMinigames do
  use Ecto.Migration

  def change do
    create table(:prizes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :stock, :integer
      add :image, :string

      timestamps(type: :utc_datetime)
    end
  end
end
