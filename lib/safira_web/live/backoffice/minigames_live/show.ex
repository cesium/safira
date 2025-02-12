defmodule SafiraWeb.Backoffice.MinigamesLive.Show do
  use SafiraWeb, :backoffice_view

  alias Safira.Accounts
  alias Safira.Inventory
  alias Safira.Store

  import SafiraWeb.Helpers
  import SafiraWeb.Components.Table
  import SafiraWeb.Components.TableSearch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    case Store.list_items_type_prize(params) do
      {:ok, {items, meta}} ->
        {:noreply,
         socket
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:current_page, :show)
         |> stream(:items, items, reset: true)}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
