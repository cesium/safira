defmodule SafiraWeb.Landing.FAQLive.Index do
  use SafiraWeb, :landing_view

  alias Safira.{Companies, Event}
  import SafiraWeb.Landing.FAQLive.Components.{Faq, FindUs}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:faqs, Event.list_faqs())}
  end
end
