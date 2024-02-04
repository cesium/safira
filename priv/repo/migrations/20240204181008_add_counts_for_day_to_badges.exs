defmodule Safira.Repo.Migrations.AddCountsForDayToBadges do
  use Ecto.Migration

  def change do
    alter table(:badges) do
      add :counts_for_day, :boolean, default: true
    end
  end
end
