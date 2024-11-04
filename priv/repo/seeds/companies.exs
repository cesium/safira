defmodule Safira.Repo.Seeds.Companies do
  alias Safira.{Companies, Repo}
  alias Safira.Companies.{Company, Tier}

  @companies File.read!("priv/fake/companies.txt") |> String.split("\n") |> Enum.map(&String.split(&1, ";"))

  def run do
    case Companies.list_tiers() do
      [] ->
        seed_tiers()
      _ ->
        Mix.shell().error("Found tiers, aborting seeding tiers.")
    end
    case Companies.list_companies() do
      [] ->
        seed_companies()
      _  ->
        Mix.shell().error("Found companies, aborting seeding companies.")
    end
  end

  defp seed_companies do
    for company <- @companies do
      {name, url, tier} = {Enum.at(company, 0), Enum.at(company, 1), Enum.random(tiers) |> elem(1)}

      company_seed = %{
        name: name,
        url: url,
        tier_id: tier.id
      }

      changeset = Companies.change_company(%Company{}, company_seed)

      case Repo.insert(changeset) do
        {:ok, _} -> :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert company: #{company_seed.name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

  defp seed_tiers do
    tiers =
      [
        %Tier{
          name: "Gold",
          priority: 0
        },
        %Tier{
          name: "Silver",
          priority: 1
        },
        %Tier{
          name: "Bronze",
          priority: 2
        }
      ] |> Enum.map(&Repo.insert(&1))
  end
end

Safira.Repo.Seeds.Companies.run()
