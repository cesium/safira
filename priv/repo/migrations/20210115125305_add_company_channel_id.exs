defmodule Safira.Repo.Migrations.AddCompanyChannelId do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add: channel_id, :string
    end
  end
end
