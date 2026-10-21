defmodule Safira.Repo.Migrations.CreateScratchCardSymbols do
  use Ecto.Migration

  def change do
    create table(:scratch_card_symbols, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :image, :string

      timestamps(type: :utc_datetime)
    end
  end
end
