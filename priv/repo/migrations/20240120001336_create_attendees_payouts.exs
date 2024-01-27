defmodule Safira.Repo.Migrations.CreateAttendeesPayouts do
  use Ecto.Migration

  def change do
    create table(:attendees_payouts) do
      add :attendee_id, references(:attendees, on_delete: :delete_all, type: :uuid)
      add :payout_id, references(:payouts, on_delete: :delete_all)
      add :bet, :integer
      add :tokens, :integer

      timestamps()
    end

    create index(:attendees_payouts, [:attendee_id])
    create index(:attendees_payouts, [:payout_id])
  end
end
