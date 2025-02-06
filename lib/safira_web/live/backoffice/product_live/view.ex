defmodule SafiraWeb.Backoffice.ProductLive.View do
  use SafiraWeb, :backoffice_view

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

end
