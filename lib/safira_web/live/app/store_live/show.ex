defmodule SafiraWeb.App.StoreLive.Show do
  use SafiraWeb, :app_view

  alias Safira.{Accounts, Store}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Store.subscribe_to_product_update(id)
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply,
     socket
     |> assign(:current_page, :store)
     |> assign(:product, Store.get_product!(id))}
  end

  @impl true
  def handle_info(updated_product, socket) do
    {:noreply, assign(socket, product: updated_product)}
  end

  @impl true
  def handle_event("purchase", _params, socket) do
    attendee = Accounts.get_user_attendee(socket.assigns.current_user.id)
    product = Store.get_product!(socket.assigns.product.id)

    Store.purchase_product(product, attendee)

    {:noreply,
     socket
     |> assign(:product, Store.get_product!(socket.assigns.product.id))
     |> assign(
       :current_user,
       Map.put(
         socket.assigns.current_user,
         :attendee,
         Accounts.get_user_attendee(socket.assigns.current_user.id)
       )
     )}
  end

  def can_purchase?(product, attendee) do
    Store.can_attendee_purchase_product(product, attendee)
  end
end
