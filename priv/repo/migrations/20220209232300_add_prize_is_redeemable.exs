defmodule Safira.Repo.Migrations.AddRedeemedQuantity do
  use Ecto.Migration

  def change do
    alter table(:attendee_prizes) do
      add :is_redeemable, :boolean
    end

  end
end
