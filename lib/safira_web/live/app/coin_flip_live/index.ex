defmodule SafiraWeb.App.CoinFlipLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.App.CoinFlipLive.Components.ResultModal
  import SafiraWeb.App.CoinFlipLive.Components.Room

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
     |> assign(:playing, false)
     |> stream(:room_list, Minigames.list_coin_flip_rooms())}
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
    params = Map.put(params, "player1_id", socket.assigns.current_user.attendee.id)

    case Minigames.create_coin_flip_room(params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> stream_insert(:room_list, room)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete-room", params, socket) do
    params = Map.put(params, "player1_id", socket.assigns.current_user.attendee.id)

    case Minigames.delete_coin_flip_room(Minigames.get_coin_flip_room!(params["room_id"])) do
      {:ok, _room} ->
        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("join-room", params, socket) do
    case Minigames.join_coin_flip_room(params["room_id"], socket.assigns.current_user.attendee) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> assign(:playing, true)}

      {:error, msg} ->
        {:noreply,
         socket
         |> put_flash(:error, msg)}
    end
  end

  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:playing, nil)}
  end

  @impl true
  def handle_event("animation-done", %{"room_id" => room_id}, socket) do
    room = Minigames.get_coin_flip_room!(room_id) |> Map.put(:finished, true)

    {:noreply,
     socket
     # Set the wheel to not in spin mode
     |> stream_delete(:room_list, room)
     |> stream_insert(:room_list, room)}
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
    {:noreply,
     socket
     |> stream_insert(:room_list, room)}
  end

  @impl true
  def handle_info({"delete", deleted_room}, socket) do
    {:noreply,
     socket
     |> stream_delete(
       :room_list,
       deleted_room
     )}
  end

  @impl true
  def handle_info({"update", room}, socket) do
    {:noreply,
     socket
     |> stream_insert(:room_list, room)}
  end

  @impl true
  def handle_info({"is_active", value}, socket) do
    {:noreply, socket |> assign(:wheel_active?, value)}
  end

  defp can_spin?(wheel_active?, tokens, price, in_spin?) do
    !in_spin? && wheel_active? && tokens >= price
  end
end
