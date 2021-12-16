defmodule Safira.Repo.Migrations.AddDailyToken do
  use Ecto.Migration

  def change do
    create table(:daily_tokens) do
      add :attendee_id, references(:attendees, on_delete: :delete_all, type: :uuid)
      add :day, :utc_datetime
      add :quantity, :integer

      timestamps()
    end
  end
end
