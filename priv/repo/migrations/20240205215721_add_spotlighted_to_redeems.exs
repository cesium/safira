defmodule Safira.Repo.Migrations.AddSpotlightedToRedeems do
  use Ecto.Migration

  def change do
    alter table(:redeems) do
      add :spotlighted, :boolean, default: false
    end
  end
end
