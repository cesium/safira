defmodule Safira.Repo.Migrations.CreateActivitiesSpeakers do
  use Ecto.Migration

  def change do
    create table(:activities_speakers, primary_key: false) do
      add :activity_id, references(:activities, type: :binary_id, on_delete: :delete_all),
        primary_key: true

      add :speaker_id, references(:speakers, type: :binary_id, on_delete: :delete_all),
        primary_key: true
    end

    create index(:activities_speakers, [:activity_id])
    create index(:activities_speakers, [:speaker_id])
  end
end
