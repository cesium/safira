defmodule Safira.Repo.Migrations.CreatePrizes do
  use Ecto.Migration

  def change do
    create table(:prizes) do
      add :name, :string
      add :stock, :integer
      add :probability, :float
      add :avatar, :string
      add :max_amount_per_attendee, :integer

      timestamps()
    end

  end
end
