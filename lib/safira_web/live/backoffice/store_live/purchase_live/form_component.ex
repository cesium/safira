defmodule SafiraWeb.Backoffice.ProductLive.PurchaseLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Inventory
  alias Safira.Store

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <div class="flex flex-col">
          <p class="text-center text-2xl mb-4 ml-12">Are you sure?</p>
          <p class="text-center pb-6">
            <%= gettext(
              "Are you sure you want to %{title} this purchase?",
              title:
                if @title == "Redeemed Purchase" do
                  "redeem"
                else
                  "return"
                end
            ) %>
          </p>
          <div class="flex justify-center space-x-8">
            <.button phx-click="cancel" class="w-full" phx-target={@myself} type="button">
              Cancel
            </.button>
            <%= if @title == "Redeemed Purchase" do %>
              <.button phx-click="confirm-redemed" class="w-full" phx-target={@myself} type="button">
                Redeem
              </.button>
            <% else %>
              <.button phx-click="confirm-return" class="w-full" phx-target={@myself} type="button">
                Return
              </.button>
            <% end %>
          </div>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def handle_event("confirm-redemed", _params, socket) do
    case Inventory.update_item(socket.assigns.item, %{redeemed_at: DateTime.utc_now()}) do
      {:ok, _item} ->
        {:noreply, socket |> push_patch(to: ~p"/dashboard/store/products/purchases")}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("confirm-return", _params, socket) do
    id = socket.assigns.item.id

    case Store.create_refund_transaction(id) do
      {:ok, _} ->
        {:noreply, socket |> push_patch(to: socket.assigns.patch)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, socket |> push_patch(to: ~p"/dashboard/store/products/purchases")}
  end
end
