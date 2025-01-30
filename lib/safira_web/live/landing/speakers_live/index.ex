defmodule SafiraWeb.Landing.SpeakersLive.Index do
  use SafiraWeb, :landing_view

  import SafiraWeb.Landing.SpeakersLive.Components.Speakers

  alias Safira.Event

  on_mount {SafiraWeb.VerifyFeatureFlag, "speakers_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:params, params)}
  end
end
