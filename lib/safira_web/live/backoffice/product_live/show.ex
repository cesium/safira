defmodule SafiraWeb.Backoffice.ProductLive.Show do
  use SafiraWeb, :backoffice_view

  alias Safira.Store

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:current_page, :store)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, Store.get_product!(id))}
  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
