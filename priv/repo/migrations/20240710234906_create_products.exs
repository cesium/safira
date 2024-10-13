defmodule Safira.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :text
      add :image, :string
      add :price, :integer
      add :stock, :integer
      add :max_per_user, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
