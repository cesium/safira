defmodule Safira.Repo.Migrations.ChangeSpotlightColumn do
  use Ecto.Migration

  def change do
    alter table(:spotlights) do
      remove :active
      add :end, :utc_datetime
    end
  end
end
