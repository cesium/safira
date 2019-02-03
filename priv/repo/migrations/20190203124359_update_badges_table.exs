defmodule Safira.Repo.Migrations.UpdateBadgesTable do
  use Ecto.Migration

  def change do
    alter table(:badges) do
      add :type, :integer
    end
  end
end
