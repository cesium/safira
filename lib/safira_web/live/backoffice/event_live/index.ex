defmodule SafiraWeb.Backoffice.EventLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Event

  on_mount {SafiraWeb.StaffRoles, show: %{"event" => ["show"]}, edit: %{"event" => ["edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    registrations_open = Event.registrations_open?()
    start_time = Event.get_event_start_time!()
    form = to_form(%{"registrations_open" => registrations_open, "start_time" => start_time})

    {:ok,
     socket
     |> assign(:current_page, :event)
     |> assign(form: form)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
