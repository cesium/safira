defmodule Safira.Repo.Migrations.AddBeginEndBadges do
  use Ecto.Migration

  def change do
    alter table(:badges) do
      add :begin_badge, :utc_datetime, null: false
      add :end_badge, :utc_datetime, null: false
  end
end
