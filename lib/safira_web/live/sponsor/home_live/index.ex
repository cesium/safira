defmodule SafiraWeb.Sponsor.HomeLive.Index do
  use SafiraWeb, :sponsor_view

  alias Safira.Accounts

  import SafiraWeb.Sponsor.HomeLive.Components.Attendee
  import SafiraWeb.Components.Table

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Accounts.list_attendees(params) do
      {:ok, {attendees, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :visitors)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:visitors, attendees, reset: true)}

      {:error, _} ->
        {:error, socket}
    end
  end

  defp get_attendee_image(attendee) do
    "/images/attendee.svg"
  end
end
