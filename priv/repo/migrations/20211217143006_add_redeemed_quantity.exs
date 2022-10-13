defmodule Safira.Repo.Migrations.AddRedeemedQuantity do
  use Ecto.Migration

  def change do
    alter table(:buys) do
      add :redeemed, :integer, null: false, default: 0
    end
  end
end
