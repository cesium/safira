defmodule Safira.Repo.Migrations.AddPrizeQuantity do
  use Ecto.Migration

  def change do
    alter table(:attendees_prizes) do
      add :redeemed, :integer, null: false, default: 0
    end

  end
end
