defmodule Safira.Repo.Migrations.UpdateRedeemablesTable do
  use Ecto.Migration

  def change do
    rename table("redeemables"), :avatar, to: :img
    rename table("redeemables"), :redeem_limit, to: :stock

    alter table("redeemables") do
      remove :num_redeems
    end
  end
end
