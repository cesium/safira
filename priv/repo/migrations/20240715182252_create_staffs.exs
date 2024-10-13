defmodule Safira.Repo.Migrations.CreateStaffs do
  use Ecto.Migration

  def change do
    create table(:staffs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :role_id, references(:roles, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:staffs, [:user_id])
  end
end
