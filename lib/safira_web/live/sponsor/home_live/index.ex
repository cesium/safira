defmodule SafiraWeb.Sponsor.HomeLive.Index do
  use SafiraWeb, :sponsor_view

  alias Safira.Accounts

  import SafiraWeb.Sponsor.HomeLive.Components.Attendee

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:current_page, :visitors)
     |> stream(:visitors, Accounts.list_attendees())}
  end
end
