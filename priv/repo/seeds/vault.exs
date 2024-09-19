defmodule Safira.Repo.Seeds.Vault do
  alias Safira.Inventory
  alias Safira.Repo
  alias Safira.Accounts.Attendee
  alias Safira.Store.Product

  def run do
    case Inventory.list_items() do
      [] ->
        seed_items()
      _  ->
        Mix.shell().error("Found vaults, aborting seeding vaults.")
    end
  end

  def seed_items do
    attendees = Repo.all(Attendee)
    products = Repo.all(Product)

    for attendee <- attendees do
      for product <- products do
        item_seed = %{
          attendee_id: attendee.id,
          product_id: product.id,
          type: "product",
        }

        changeset = Inventory.Item.changeset(%Inventory.Item{}, item_seed)

        case Repo.insert(changeset) do
          {:ok, _} -> :ok
          {:error, changeset} ->
            Mix.shell().error("Failed to insert item: #{product.name} at vault")
            Mix.shell().error(Kernel.inspect(changeset.errors))
        end
      end
    end
  end
end

Safira.Repo.Seeds.Vault.run()
