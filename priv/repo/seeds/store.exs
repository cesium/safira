defmodule Safira.Repo.Seeds.Store do
  alias Safira.{Repo, Store}

  @products File.read!("priv/fake/products.txt") |> String.split("\n") |> Enum.map(&String.split(&1, ";"))

  def run do
    case Store.list_products() do
      [] ->
        seed_store()
      _  ->
        Mix.shell().error("Found products, aborting seeding products.")
    end
  end

  def seed_store do
    for product <- @products do
      {name, description} = {Enum.at(product, 0), Enum.at(product, 1)}

      product_seed = %{
        name: name,
        description: description,
        price: Enum.random([100, 200, 300, 400, 500]),
        stock: Enum.random([10, 20, 30, 40, 50]),
        max_per_user: Enum.random([1, 2, 3, 4, 5])
      }

      changeset = Store.Product.changeset(%Store.Product{}, product_seed)

      case Repo.insert(changeset) do
        {:ok, _} -> :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert product: #{product_seed.name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end
end

Safira.Repo.Seeds.Store.run()
