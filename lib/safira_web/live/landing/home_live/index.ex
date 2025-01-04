defmodule SafiraWeb.Landing.HomeLive.Index do
  alias Safira.Companies
  use SafiraWeb, :landing_view

  import SafiraWeb.Landing.HomeLive.Components.{Hero, Partners, Pitch, Sponsors, Speakers}
  import SafiraWeb.Landing.Components.Schedule

  alias Safira.{Activities, Event}

  @impl true
  def mount(_params, _session, socket) do
    speakers = Activities.list_highlighted_speakers()

    {:ok,
     socket
     |> assign(:tiers, Companies.list_tiers_with_companies())
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())
     |> assign(:has_highlighted_speakers?, speakers != [])
     |> assign(:registrations_open?, Event.registrations_open?())
     |> assign(:has_sponsors?, Companies.get_companies_count() > 0)
     |> assign(:has_schedule?, Activities.get_activities_count() > 0)
     |> stream(:speakers, speakers |> Enum.shuffle())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:params, params)}
  end
end
