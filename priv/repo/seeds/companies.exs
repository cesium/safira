defmodule Safira.Repo.Seeds.Companies do
  alias NimbleCSV.RFC4180, as: CSV

  alias Safira.Accounts.User
  alias Safira.{Companies, Repo}
  alias Safira.Companies.{Company, Tier}

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
    tiers = Companies.list_tiers()
    File.stream!("priv/fake/companies.csv")
    |> CSV.parse_stream()
    |> Stream.map(fn [name, email, handle, url, tier] ->
      actual_tier = case tier do
        "gold" -> Enum.at(tiers, 0)
        "silver" -> Enum.at(tiers, 1)
        "bronze" -> Enum.at(tiers, 2)
      end

      company_seed = %{
        "user" => %{
          "email" => email,
          "handle" => handle,
          "password" => "password1234",
          "name" => name
        },
        "name" => name,
        "url" => url,
        "tier_id" => actual_tier.id
      }

      case Companies.upsert_company_and_user(%Company{}, company_seed) do
        {:ok, _} -> :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert company: #{company_seed.name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end)
    |> Stream.run()
  end

  defp seed_tiers do
    tiers =
      [
        %Tier{
          name: "Gold",
          full_cv_access: true,
          priority: 0
        },
        %Tier{
          name: "Silver",
          full_cv_access: false,
          priority: 1
        },
        %Tier{
          name: "Bronze",
          full_cv_access: false,
          priority: 2
        }
      ] |> Enum.map(&Repo.insert(&1))
  end
end

Safira.Repo.Seeds.Companies.run()
