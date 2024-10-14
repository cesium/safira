defmodule SafiraWeb.Landing.HomeLive.Index do
  use SafiraWeb, :landing_view

  import SafiraWeb.Landing.HomeLive.Components.Hero

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
