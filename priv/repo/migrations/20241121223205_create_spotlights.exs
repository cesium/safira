defmodule Safira.Repo.Migrations.CreateSpotlights do
  use Ecto.Migration

  def change do
    create table(:spotlights) do
      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all),
        null: false
      add :end, :utc_datetime

      timestamps(type: :utc_datetime)
    end
    create unique_index(:spotlights, [:company_id])

  end
end
