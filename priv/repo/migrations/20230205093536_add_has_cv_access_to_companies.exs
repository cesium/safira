defmodule Safira.Repo.Migrations.AddHasCvAccessToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :has_cv_access, :boolean, default: false
    end
  end
end
