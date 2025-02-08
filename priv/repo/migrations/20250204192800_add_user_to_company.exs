defmodule Safira.Repo.Migrations.AddUserToCompany do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
    end

    alter table(:tiers) do
      add :full_cv_access, :boolean, default: false
    end

    create unique_index(:companies, [:user_id])
  end
end
