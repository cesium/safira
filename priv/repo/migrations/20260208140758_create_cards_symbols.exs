defmodule Safira.Repo.Migrations.CreateCardsSymbols do
  use Ecto.Migration

  def change do
    create table(:cards_symbols) do
      add :scratch_card_id, references(:scratch_cards, type: :binary_id, on_delete: :delete_all)

      add :scratch_card_symbol_id,
          references(:scratch_card_symbols, type: :binary_id, on_delete: :delete_all)
    end
  end
end
