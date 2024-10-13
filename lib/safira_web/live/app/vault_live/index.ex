defmodule SafiraWeb.App.VaultLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.App.VaultLive.Components.Item

  alias Safira.Inventory

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:items, Inventory.list_attendee_items(socket.assigns.current_user.attendee.id))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:current_page, :vault)}
  end

  defp get_item_data(item) do
    case item.type do
      :product ->
        item.product

      :prize ->
        item.prize
    end
  end

  defp get_item_image(type, data) do
    case type do
      :product ->
        Uploaders.Product.url({data.image, data}, :original)

      :prize ->
        Uploaders.Prize.url({data.image, data}, :original)
    end
  end
end
