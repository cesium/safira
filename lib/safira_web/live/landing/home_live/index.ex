defmodule SafiraWeb.Landing.HomeLive.Index do
  alias Safira.Companies
  use SafiraWeb, :landing_view

  import SafiraWeb.Landing.HomeLive.Components.{Hero, Pitch, Sponsors}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:tiers, Companies.list_tiers_with_companies())}
  end
end
