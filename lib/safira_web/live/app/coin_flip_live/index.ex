defmodule SafiraWeb.App.CoinFlipLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.App.WheelLive.Components.ResultModal

  alias Safira.Minigames

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Minigames.subscribe_to_coin_flip_config_update("price")
      Minigames.subscribe_to_coin_flip_config_update("is_active")
      Minigames.subscribe_to_coin_flip_rooms_update()
    end

    {:ok,
     socket
     |> assign(:current_page, :coin_flip)
     |> assign(:attendee_tokens, socket.assigns.current_user.attendee.tokens)
     |> assign(:wheel_price, Minigames.get_coin_flip_fee())
     |> assign(:result, nil)
     |> assign(:wheel_active?, Minigames.wheel_active?())
     |> assign(:room_list, Minigames.list_coin_flip_rooms())}
  end

  @impl true
  def handle_event("spin-wheel", _params, socket) do
    {:noreply,
     socket
     # Set the wheel to spin mode
     |> assign(:in_spin?, true)
     # Deduct the price from the attendee's tokens (client side)
     |> assign(:attendee_tokens, socket.assigns.attendee_tokens - socket.assigns.wheel_price)
     |> push_event("spin-wheel", %{})}
  end

  def handle_event("create-room", params, socket) do
    IO.inspect(params)
    params = Map.put(params, "player1_id", socket.assigns.current_user.attendee.id)

    case Minigames.create_coin_flip_room(params) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> assign(:room_list, Minigames.list_coin_flip_rooms())}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete-room", params, socket) do
    IO.inspect(params)
    params = Map.put(params, "player1_id", socket.assigns.current_user.attendee.id)

    case Minigames.delete_coin_flip_room(Minigames.get_coin_flip_room!(params["room_id"])) do
      {:ok, _room} ->
        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:result, nil)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({"price", value}, socket) do
    {:noreply, socket |> assign(:wheel_price, value)}
  end

  @impl true
  def handle_info({"create", room}, socket) do
    if Enum.any?(socket.assigns.room_list, fn r -> r.id == room.id end) do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> assign(:room_list, [room | socket.assigns.room_list])}
    end
  end

  @impl true
  def handle_info({"delete", deleted_room}, socket) do
    IO.inspect(deleted_room)

    {:noreply,
     socket
     |> assign(
       :room_list,
       socket.assigns.room_list |> Enum.reject(fn room -> room.id == deleted_room.id end)
     )}
  end

  @impl true
  def handle_info({"is_active", value}, socket) do
    {:noreply, socket |> assign(:wheel_active?, value)}
  end

  defp can_spin?(wheel_active?, tokens, price, in_spin?) do
    !in_spin? && wheel_active? && tokens >= price
  end
end
