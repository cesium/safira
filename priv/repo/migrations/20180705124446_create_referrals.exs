defmodule Safira.Repo.Migrations.CreateReferrals do
  use Ecto.Migration

  def change do
    create table(:referrals, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :available, :boolean, default: true, null: true
      add :badge_id, references(:badges, on_delete: :delete_all)

      timestamps()
    end

    create index(:referrals, [:badge_id])

  end
end
