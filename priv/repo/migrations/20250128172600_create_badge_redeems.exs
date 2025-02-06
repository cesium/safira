defmodule Safira.Repo.Migrations.CreateBadgeRedeems do
  use Ecto.Migration

  def change do
    create table(:badge_redeems, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :badge_id, references(:badges, on_delete: :nothing, type: :binary_id), null: false

      add :attendee_id, references(:attendees, on_delete: :delete_all, type: :binary_id),
        null: false

      add :redeemed_by_id, references(:staffs, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:badge_redeems, [:attendee_id, :badge_id])
    create index(:badge_redeems, [:badge_id])
    create index(:badge_redeems, [:attendee_id])
    create index(:badge_redeems, [:redeemed_by_id])
  end
end
