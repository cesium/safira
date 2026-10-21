defmodule Safira.Repo.Migrations.CreateScratchCards do
  use Ecto.Migration

  def change do
    create table(:scratch_cards, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :attendee_id, references(:attendees, type: :binary_id, on_delete: :delete_all)
      add :drop_id, references(:scratch_card_drops, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:scratch_cards, [:attendee_id])
    create index(:scratch_cards, [:drop_id])
  end
end
