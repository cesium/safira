defmodule Safira.Repo.Migrations.AddCvTable do
  use Ecto.Migration

  def change do
    create table(:cvs) do
      add :user_id, references(:attendees, on_delete: :delete_all, type: :uuid)
      add :cv, :string

      timestamps()
    end
  end
end
