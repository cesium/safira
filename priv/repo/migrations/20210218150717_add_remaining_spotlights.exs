defmodule Safira.Repo.Migrations.AddRemainingSpotlights do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :remaining_spotlights, :integer
    end
  end
end
