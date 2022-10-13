defmodule Safira.Repo.Migrations.AddIsRedeemableToRedeemables do
  use Ecto.Migration

  def change do
    alter table(:redeemables) do
      add :is_redeemable, :boolean, default: true, null: false
    end
  end
end
