defmodule Safira.Repo.Migrations.AddTokenBalanceAttendee do
  use Ecto.Migration

  def change do

    alter table(:attendees) do
      add :token_balance, :integer
  end
end
end
