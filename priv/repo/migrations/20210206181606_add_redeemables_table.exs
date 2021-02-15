defmodule Safira.Repo.Migrations.AddRedeemablesTable do
  use Ecto.Migration

  def change do
    create table(:redeemables) do
      add :avatar, :string
      add :name, :string
      add :description, :text
      add :price, :integer
      add :redeem_limit, :integer
      add :num_redeems, :integer
      add :max_per_user, :integer

      timestamps()
    end
  end
end
