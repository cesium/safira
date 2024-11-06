defmodule SafiraWeb.Landing.HomeLive.Index do
  alias Safira.Companies
  use SafiraWeb, :landing_view

  import SafiraWeb.Landing.HomeLive.Components.{Hero, Partners, Pitch, Sponsors, Speakers}

  alias Safira.{Activities, Event}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:tiers, Companies.list_tiers_with_companies())
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())
     |> stream(:speakers, Activities.list_highlighted_speakers())}
  end
end
