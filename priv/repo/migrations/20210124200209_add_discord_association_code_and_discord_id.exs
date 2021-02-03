defmodule Safira.Repo.Migrations.AddDiscordAssociationCodeAndDiscordId do
  use Ecto.Migration

  def change do
    alter table(:attendees) do
      add :discord_association_code, :uuid, null: false
      add :discord_id, :string
    end

      create unique_index(:attendees, [:discord_association_code])
      create unique_index(:attendees, [:discord_id])
  end
end
