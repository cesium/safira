defmodule Safira.Repo.Migrations.UpdateRedeemablesTable do
  use Ecto.Migration

  def change do
    rename table("redeemables"), :avatar, to: :img

  end
end
