defmodule SafiraWeb.Backoffice.ProductLive.PurchaseLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Inventory
  alias Safira.Store

  import SafiraWeb.Helpers
  import SafiraWeb.Components.Table
  import SafiraWeb.Components.TableSearch

  on_mount {SafiraWeb.StaffRoles,
            show: %{"purchases" => ["show"]},
            redeem: %{"purchases" => ["redeem"]},
            refund: %{"purchases" => ["refund"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Store.list_purchases(params) do
      {:ok, {items, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :store)
         |> assign(:params, params)
         |> assign(:meta, meta)
         |> stream(:items, items, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Purchases")
  end

  def apply_action(socket, :redeem, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redeem Purchase")
    |> assign(:item, Inventory.get_item!(id))
  end

  def apply_action(socket, :refund, %{"id" => id}) do
    socket
    |> assign(:page_title, "Refund Purchase")
    |> assign(:item, Inventory.get_item!(id))
  end
end
