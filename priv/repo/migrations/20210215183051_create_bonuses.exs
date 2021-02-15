defmodule Safira.Repo.Migrations.CreateBonuses do
  use Ecto.Migration

  def change do
    create table(:bonuses) do
      add :count, :integer
      add :attendee_id, references(:attendees, on_delete: :nothing, type: :uuid)
      add :company_id, references(:companies, on_delete: :nothing)

      timestamps()
    end

    create index(:bonuses, [:attendee_id])
    create index(:bonuses, [:company_id])

    create unique_index(:bonuses, [:attendee_id, :company_id], name: :unique_bonus)
  end
end
