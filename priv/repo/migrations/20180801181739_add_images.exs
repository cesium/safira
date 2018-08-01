defmodule Safira.Repo.Migrations.AddImages do
  use Ecto.Migration

  def change do
    alter table(:attendees) do
      add :avatar, :string
    end

    alter table(:badges) do
      add :avatar, :string
    end
  end
end
