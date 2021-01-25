defmodule Safira.Repo.Migrations.AddAssociationCodeAndDiscordId do
  use Ecto.Migration

  def change do
    alter table(:attendees) do
      add :association_code, :uuid, null: false
      add :discord_id, :string
    end

      create unique_index(:attendees, [:discord_id])
  end
end
