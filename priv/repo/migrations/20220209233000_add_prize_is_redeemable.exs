defmodule Safira.Repo.Migrations.AddPrizesRedeemablee do
  use Ecto.Migration

  def change do
    alter table(:prizes) do
      add :is_redeemable, :boolean
    end

  end
end
