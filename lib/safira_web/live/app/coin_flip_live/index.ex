defmodule SafiraWeb.App.CoinFlipLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.App.CoinFlipLive.Components.Room
  import SafiraWeb.App.CoinFlipLive.Components.ResultModal

  alias Safira.Minigames

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Minigames.subscribe_to_coin_flip_config_update("fee")
      Minigames.subscribe_to_coin_flip_config_update("is_active")
      Minigames.subscribe_to_coin_flip_rooms_update()
    end

    previous_room_list =
      Minigames.list_coin_flip_rooms()
      |> Enum.filter(& &1.finished)
      |> Enum.take(4)

    {:ok,
     socket
     |> assign(:current_page, :coin_flip)
     |> assign(:attendee_tokens, socket.assigns.current_user.attendee.tokens)
     |> assign(:coin_flip_fee, Minigames.get_coin_flip_fee())
     |> assign(:result, nil)
     |> assign(:coin_flip_active?, Minigames.coin_flip_active?())
     |> assign(:won, false)
     |> assign(:bet, 10)
     |> stream(:room_list, Minigames.list_coin_flip_rooms() |> Enum.filter(&(!&1.finished)))
     |> stream(:previous_room_list, previous_room_list)}
  end

  def handle_event("create-room", _params, socket) do
    params = %{
      "attendee_id" => socket.assigns.current_user.attendee.id,
      "bet" => socket.assigns.bet
    }

    case Minigames.create_coin_flip_room(params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> assign(:attendee_tokens, socket.assigns.attendee_tokens - socket.assigns.bet)
         |> stream_insert(:room_list, room)}

      {:error, msg} ->
        {:noreply, socket |> put_flash(:error, msg)}
    end
  end

  def handle_event("delete-room", params, socket) do
    params = Map.put(params, "player1_id", socket.assigns.current_user.attendee.id)

    case Minigames.delete_coin_flip_room(Minigames.get_coin_flip_room!(params["room_id"])) do
      {:ok, room} ->
        {:noreply,
         socket
         |> assign(:attendee_tokens, socket.assigns.attendee_tokens + room.bet)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("join-room", params, socket) do
    case Minigames.join_coin_flip_room(params["room_id"], socket.assigns.current_user.attendee) do
      {:ok, room} ->
        {:noreply,
         socket
         |> assign(:attendee_tokens, socket.assigns.attendee_tokens - room.bet)
         |> assign(:won, false)}

      {:error, msg} ->
        {:noreply,
         socket
         |> put_flash(:error, msg)}
    end
  end

  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:won, false)}
  end

  def handle_event("animation-done", %{"room_id" => room_id}, socket) do
    room = Minigames.get_coin_flip_room!(room_id) |> Map.put(:finished, true)

    attendee_tokens =
      if won?(room, socket.assigns.current_user) do
        socket.assigns.attendee_tokens + round(room.bet * 2 * (1 - socket.assigns.coin_flip_fee))
      else
        socket.assigns.attendee_tokens
      end

    {
      :noreply,
      socket
      # Set the wheel to not in spin mode
      |> stream_delete(:room_list, room)
      |> stream_insert(:previous_room_list, room, limit: 4, at: 0)
      |> assign(:attendee_tokens, attendee_tokens)
      #  |> assign(:won, won?(room, socket.assigns.current_user))
    }
  end

  @impl true
  def handle_event("decrease-bet", _params, socket) do
    {:noreply,
     socket
     |> assign(:bet, socket.assigns.bet - 10)}
  end

  @impl true
  def handle_event("increase-bet", _params, socket) do
    {:noreply,
     socket
     |> assign(:bet, socket.assigns.bet + 10)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({"fee", value}, socket) do
    {:noreply, socket |> assign(:coin_flip_fee, value)}
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
    if room.finished do
      {:noreply,
       socket
       #  |> stream_delete(:room_list, room)
       |> stream_insert(:previous_room_list, room)}
    else
      {:noreply,
       socket
       |> stream_insert(:room_list, room)}
    end
  end

  @impl true
  def handle_info({"is_active", value}, socket) do
    {:noreply, socket |> assign(:coin_flip_active?, value)}
  end

  defp won?(room, current_user) do
    (room.result == "heads" and room.player1_id == current_user.attendee.id) or
      (room.result == "tails" and room.player2_id == current_user.attendee.id)
  end
end
