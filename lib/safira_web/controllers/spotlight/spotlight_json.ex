defmodule SafiraWeb.SpotlightJSON do
  @moduledoc false

  def index(%{companies: companies, spotlight: spotlight}) do
    %{
      data: for(company <- companies, do: data(company, spotlight))
    }
  end

  def current(%{company: company, spotlight: spotlight}) do
    data =
      data(company, spotlight)
      |> Map.drop([:remaining])
      |> Map.put(:badge_id, company.badge_id)

    %{
      data: data
    }
  end

  defp data(company, spotlight) do
    default = default(company)

    if spotlight && spotlight.badge_id == company.badge_id do
      Map.put(default, :end, spotlight.end)
    else
      default
    end
  end

  defp default(company) do
    %{
      id: company.id,
      name: company.name,
      remaining: company.remaining_spotlights
    }
  end
end
