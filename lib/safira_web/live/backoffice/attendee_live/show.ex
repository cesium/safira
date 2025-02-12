defmodule SafiraWeb.Backoffice.AttendeeLive.Show do
  use SafiraWeb, :backoffice_view

  alias Safira.Accounts

  on_mount {SafiraWeb.StaffRoles,
            show: %{"attendees" => ["show"]}, edit: %{"attendees" => ["edit"]}}

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :attendees)}
  end

  def handle_params(%{"id" => attendee_id} = params, _, socket) do
    {:noreply,
     socket
     |> assign(:attendee, Accounts.get_attendee!(attendee_id, preloads: [:user]))
     |> assign(:params, params)}
  end
end
