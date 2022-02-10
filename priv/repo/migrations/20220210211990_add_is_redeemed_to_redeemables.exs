defmodule Safira.Repo.Migrations.AddIsRedeemedToRedeemables do
  use Ecto.Migration

  def change do
    alter table(:redeemables) do
      add :is_redeemed, :boolean, default: true, null: false
    end

  end
end
