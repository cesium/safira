defmodule Safira.Repo.Migrations.CreateUsersBadges do
  use Ecto.Migration

  def change do
    create table(:users_badges) do
      add :user_id, references(:users, on_delete: :nothing)
      add :badge_id, references(:badges, on_delete: :nothing)
      add :staff_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:users_badges, [:user_id])
    create index(:users_badges, [:badge_id])
    create index(:users_badges, [:staff_id])
    create unique_index(:users_badges, [:user_id, :badge_id], name: :unique_user_badge)
  end
end
