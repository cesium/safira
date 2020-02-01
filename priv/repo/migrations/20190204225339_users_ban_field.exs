defmodule Safira.Repo.Migrations.UsersBanField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :ban, :boolean, default: false
    end
  end
end
