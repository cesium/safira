defmodule Safira.Repo.Migrations.AddBages do
  use Ecto.Migration

  def change do
    create table(:badges) do
      add :begin, :utc_datetime
      add :end, :utc_datetime
      add :name, :string
      add :description, :text

      timestamps()
    end
  end
end
