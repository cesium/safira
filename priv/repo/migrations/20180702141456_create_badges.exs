defmodule Safira.Repo.Migrations.CreateBadges do
  use Ecto.Migration

  def change do
    create table(:badges) do
      add :begin, :utc_datetime
      add :end, :utc_datetime
      add :company_id, references(:users, on_delete: :nothing)
      add :name, :string
      add :description, :text

      timestamps()
    end

    create index(:badges, [:company_id])
  end
end
