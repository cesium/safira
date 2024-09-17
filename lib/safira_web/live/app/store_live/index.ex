defmodule SafiraWeb.App.StoreLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Store

  import SafiraWeb.App.StoreLive.Components.ProductCard

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:products, Store.list_products())
     |> assign(:current_page, :store)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
