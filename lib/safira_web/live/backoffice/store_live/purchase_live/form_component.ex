defmodule SafiraWeb.Backoffice.PurchaseLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Inventory
  alias Safira.Store

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 w-full">
      <h1 class="font-semibold text-xl">
        <%= confirmation_title(@action, @item.product.name) %>
      </h1>
      <div class="flex gap-6 flex-col">
        <p>
          <%= confimation_message(@action) %>
        </p>

        <div class="flex flex-row w-full gap-2">
          <.button
            phx-click="cancel"
            phx-target={@myself}
            class="w-full flex flex-row items-center justify-center"
          >
            <.icon name="hero-x-circle" class="w-5 h-5 mr-2" />
            <%= gettext("Cancel") %>
          </.button>
          <.button
            phx-click="confirm-action"
            phx-target={@myself}
            class="w-full flex flex-row items-center justify-center"
          >
            <.icon name="hero-check-circle" class="w-5 h-5 mr-2" />
            <%= confirmation_button(@action) %>
          </.button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("confirm-action", _params, socket) do
    handle_action(socket.assigns.action, socket)
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, socket |> push_patch(to: ~p"/dashboard/store/purchases")}
  end

  defp handle_action(:redeem, socket) do
    case Inventory.update_item(socket.assigns.item, %{redeemed_at: DateTime.utc_now()}) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> put_flash(:info, "This purchase was successfully marked as delivered.")
         |> push_navigate(to: ~p"/dashboard/store/purchases")}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  defp handle_action(:refund, socket) do
    id = socket.assigns.item.id

    case Store.refund_transaction(id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "This purchase was successfully refunded.")
         |> push_navigate(to: ~p"/dashboard/store/purchases")}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp confirmation_title(:redeem, name),
    do: gettext("Deliver %{product_name}", product_name: name)

  defp confirmation_title(:refund, name),
    do: gettext("Refund %{product_name}", product_name: name)

  defp confimation_message(:redeem),
    do:
      gettext(
        "Are you sure you want to mark this item as delivered? This action is not reversible."
      )

  defp confimation_message(:refund),
    do: gettext("Are you sure you want to refund this purchase? This action is not reversible.")

  defp confirmation_button(:redeem), do: gettext("Deliver")

  defp confirmation_button(:refund), do: gettext("Refund")
end
