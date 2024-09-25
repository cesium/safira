defmodule SafiraWeb.ScannerLive.Index do
  use SafiraWeb, :backoffice_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket |> assign(:modal_data, nil)}
  end

  @impl true
  def handle_event("scan", data, socket) do
    case safely_extract_id_from_url(data) do
      {:ok, id} ->
        if Safira.Accounts.attendee_exists?(id) do
          {:noreply, socket |> push_navigate(to: ~p"/dashboard/attendees/#{id}")}
        else
          {:noreply, socket |> assign(:modal_data, :not_found)}
        end

      {:error, _} ->
        {:noreply, socket |> assign(:modal_data, :invalid)}
    end
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, socket |> assign(:modal_data, nil)}
  end
end
