defmodule Safira.Repo.Migrations.AddBuysTable do
  use Ecto.Migration

  def change do
    create table(:buys) do
      add :quantity, :integer
      add :attendee_id, references(:attendees, on_delete: :delete_all, type: :uuid)
      add :redeemable_id, references(:redeemables, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:buys, [:attendee_id, :redeemable_id], name: :unique_attendee_redeemable)
  end
end
