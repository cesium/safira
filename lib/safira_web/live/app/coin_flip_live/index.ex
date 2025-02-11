defmodule SafiraWeb.App.CoinFlipLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.App.CoinFlipLive.Components.Room

  alias Safira.Minigames

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_user.attendee.ineligible do
      {:ok,
       socket
       |> put_flash(:error, "Can't play the coin flip minigame with this account.")
       |> push_navigate(to: ~p"/app")}
    else
      if connected?(socket) do
        Minigames.subscribe_to_coin_flip_config_update("fee")
        Minigames.subscribe_to_coin_flip_config_update("is_active")
        Minigames.subscribe_to_coin_flip_rooms_update()
      end

      room_list = Minigames.list_current_coin_flip_rooms()

      previous_room_list = Minigames.list_previous_coin_flip_rooms(4)

      {:ok,
       socket
       |> assign(:current_page, :coin_flip)
       |> assign(:attendee_tokens, socket.assigns.current_user.attendee.tokens)
       |> assign(:coin_flip_fee, Minigames.get_coin_flip_fee())
       |> assign(:result, nil)
       |> assign(:coin_flip_active?, Minigames.coin_flip_active?())
       |> assign(:bet, 10)
       |> stream(:room_list, room_list)
       |> assign(:room_list_count, room_list |> Enum.count())
       |> stream(:previous_room_list, previous_room_list)
       |> assign(:previous_room_list_count, previous_room_list |> Enum.count())}
    end
  end

  def handle_event("create-room", _params, socket) do
    params = %{
      "attendee_id" => socket.assigns.current_user.attendee.id,
      "bet" => socket.assigns.bet
    }

    case Minigames.create_coin_flip_room(params) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> assign(:attendee_tokens, socket.assigns.attendee_tokens - socket.assigns.bet)}

      {:error, message} ->
        {:noreply, socket |> put_flash(:error, message)}
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
         |> assign(:attendee_tokens, socket.assigns.attendee_tokens - room.bet)}

      {:error, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)}
    end
  end

  def handle_event("animation-done", %{"room_id" => room_id}, socket) do
    room = Minigames.get_coin_flip_room!(room_id) |> Map.put(:finished, true)

    attendee_tokens =
      if won?(room, socket.assigns.current_user) do
        socket.assigns.attendee_tokens + floor(room.bet * 2 * (1 - socket.assigns.coin_flip_fee))
      else
        socket.assigns.attendee_tokens
      end

    {
      :noreply,
      socket
      |> stream_delete(:room_list, room)
      |> assign(:room_list_count, socket.assigns.room_list_count - 1)
      |> stream_insert(:previous_room_list, room, limit: 4, at: 0)
      |> assign(:previous_room_list_count, socket.assigns.previous_room_list_count + 1)
      |> assign(:attendee_tokens, attendee_tokens)
    }
  end

  @impl true
  def handle_event("set-bet", %{"bet" => bet}, socket) do
    bet = if bet != "", do: String.to_integer(bet), else: 0

    {:noreply,
     socket
     |> assign(:bet, bet)}
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
    if room.player1_id == socket.assigns.current_user.attendee.id do
      {:noreply,
       socket
       |> stream_insert(:room_list, room, at: 0)
       |> assign(:room_list_count, socket.assigns.room_list_count + 1)}
    else
      {:noreply,
       socket
       |> stream_insert(:room_list, room)
       |> assign(:room_list_count, socket.assigns.room_list_count + 1)}
    end
  end

  @impl true
  def handle_info({"delete", deleted_room}, socket) do
    {:noreply,
     socket
     |> stream_delete(
       :room_list,
       deleted_room
     )
     |> assign(:room_list_count, socket.assigns.room_list_count - 1)}
  end

  @impl true
  def handle_info({"update", room}, socket) do
    if not room.finished do
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
