defmodule Safira.Repo.Migrations.AddTotalTokensAttendee do
  use Ecto.Migration

  def change do

    alter table(:attendees) do
      add :total_tokens, :integer
  end
end
end
