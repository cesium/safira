defmodule SafiraWeb.Backoffice.ProductLive.PurchaseLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
      >
      <div class="flex flex-col">
          <p class="text-center text-2xl mb-4 ml-12">Are you sure?</p>
          <div class="flex justify-center space-x-8">
            <.button phx-click="cancel-redemed" class="w-full" phx-target={@myself} type="button">
              Cancel
            </.button>
            <.button phx-click="confirm-redemed" class="w-full" phx-target={@myself} type="button">
              Redemed
            </.button>
          </div>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def handle_event("confirm-redemed", _params, socket) do
    case Inventory.update_item(%{redeemed_at: DateTime.utc_now()}) do
      {:ok, _item} ->
        {:noreply, socket |> push_patch(to: ~p"/dashboard/store/products/purchases")}
      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cancel-redemed", _params, socket) do
    {:noreply, socket |> push_patch(to: ~p"/dashboard/store/products/purchases")}
  end
end
