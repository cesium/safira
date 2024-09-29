defmodule SafiraWeb.Backoffice.EventLive.Index do
  use SafiraWeb, :backoffice_view

  alias SafiraWeb.Helpers

  def mount(_params, _session, socket) do
    registrations_open = Helpers.registrations_open?()
    start_time = Helpers.get_start_time!() |> parse_date()
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

  defp parse_date(date) do
    base_str = DateTime.to_iso8601(date)
    len = String.length(base_str)
    String.slice(base_str, 0, len - 4)
  end
end
