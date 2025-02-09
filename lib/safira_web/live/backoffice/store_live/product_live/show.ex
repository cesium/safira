defmodule SafiraWeb.Backoffice.ProductLive.Show do
  use SafiraWeb, :backoffice_view

  alias Safira.Store

  on_mount {SafiraWeb.StaffRoles,
            show: %{"products" => ["show"]}, edit: %{"products" => ["edit"]}}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Store.subscribe_to_product_update(id)
    end

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

  @impl true
  def handle_info(updated_product, socket) do
    {:noreply, assign(socket, product: updated_product)}
  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
