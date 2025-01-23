defmodule SafiraWeb.Backoffice.ScannerLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Accounts.Roles.Permissions
  alias Safira.Contest

  import SafiraWeb.Components.TableSearch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Contest.list_badges(params) do
      {:ok, {badges, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :scanner)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:badges, badges, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Badges")
  end
end
