defmodule SafiraWeb.Backoffice.ProductLive.View do
  use SafiraWeb, :backoffice_view

  alias Safira.Contest
  alias Safira.Inventory
  alias Safira.Store

  import SafiraWeb.Components.Table
  import SafiraWeb.Components.TableSearch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :view)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Store.list_purchases(params) do
      {:ok, {items, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :view)
         |> assign(:params, params)
         |> assign(:meta, meta)
         |> stream(:items, items, reset: true)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Inventory.get_item!(id)
    Store.update_product(item.product, %{stock: item.product.stock + 1})
    {:ok, _} = Inventory.delete_item(item)

    Contest.change_attendee_tokens(item.attendee, item.attendee.tokens + item.product.price)

    {:noreply, stream_delete(socket, :items, item)}
  end
end
