defmodule SafiraWeb.Landing.FAQLive.Index do
  use SafiraWeb, :landing_view

  alias Safira.Event
  import SafiraWeb.Landing.FAQLive.Components.{Faq, FindUs}

  on_mount {SafiraWeb.VerifyFeatureFlag, "faqs_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:faqs, Event.list_faqs())}
  end
end
