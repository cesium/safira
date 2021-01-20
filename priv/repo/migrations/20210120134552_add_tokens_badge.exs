defmodule Safira.Repo.Migrations.AddTokensBadge do
  use Ecto.Migration

  def change do

    alter table(:badges) do
      add :tokens, :integer
  end

  create unique_index(:badges, [:tokens])
end
end
