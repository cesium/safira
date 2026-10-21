defmodule SafiraWeb.App.GamesLive.ScratchCardLive.Index do
  use SafiraWeb, :app_view

  alias Safira.{Contest, Minigames}
  alias Safira.Uploaders

  import SafiraWeb.App.GamesLive.WheelLive.Components.ResultModal
  import SafiraWeb.App.GamesLive.WheelLive.Components.LatestWins
  import SafiraWeb.App.GamesLive.ScratchCardLive.Components.PaytableModal

  @max_wins 6

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Minigames.subscribe_to_scratch_card_config_update("is_active")
      Minigames.subscribe_to_scratch_card_config_update("price")
      Minigames.subscribe_to_scratch_card_config_update("drops")
      Minigames.subscribe_to_scratch_card_wins()
    end

    {:ok,
     socket
     |> assign(current_page: :scratch_card)
     |> assign(is_scratching?: false)
     |> assign(is_revealed: false)
     |> assign(attendee_tokens: socket.assigns.current_user.attendee.tokens)
     |> assign(scratch_card_price: Minigames.get_scratch_card_price())
     |> assign(scratch_card_active?: Minigames.scratch_card_active?())
     |> assign(result: nil)
     |> assign(:drops, Minigames.list_scratch_card_drops())
     |> assign(:latest_wins, Minigames.scratch_card_latest_wins(@max_wins))}
  end

  @impl true
  def handle_event("buy-card", _params, socket) do
    case Minigames.buy_scratch_card(socket.assigns.current_user.attendee) do
      {:ok, %{scratch_card_preloaded: scratch_card}} ->
        result =
          if scratch_card.drop do
            %{type: Minigames.get_drop_type(scratch_card.drop), drop: scratch_card.drop}
          else
            %{type: nil, drop: nil}
          end

        {:noreply,
         socket
         |> assign(:is_scratching?, true)
         |> assign(:current_scratch_card, scratch_card)
         |> assign(:current_symbols, Minigames.get_symbols_from_scratch_card(scratch_card))
         |> assign(:result, result)
         |> assign(
           :attendee_tokens,
           socket.assigns.attendee_tokens - socket.assigns.scratch_card_price
         )
         |> push_event("scratch-card", %{card_id: scratch_card.id})}

      {:error, _error} ->
        {:noreply,
         socket
         |> assign(:is_scratching?, false)
         |> put_flash(:error, "An error occurred while buying the scratch card!")}
    end
  end

  def handle_event("scratch-completed", %{"card_id" => card_id}, socket) do
    cond do
      is_nil(socket.assigns[:current_scratch_card]) ->
        {:noreply, put_flash(socket, :error, "There is no active scratch card")}

      socket.assigns.current_scratch_card.id != card_id ->
        {:noreply, put_flash(socket, :error, "Invalid scratch card")}

      true ->
        %{type: type, drop: drop} = socket.assigns.result

        {:noreply,
         socket
         |> assign(is_scratching?: false)
         |> assign(is_revealed: true)
         |> assign(
           :attendee_tokens,
           case type do
             :tokens ->
               socket.assigns.attendee_tokens + drop.tokens

             :badge ->
               Contest.get_attendee_tokens(socket.assigns.current_user.attendee)

             _ ->
               socket.assigns.attendee_tokens
           end
         )}
    end
  end

  @impl true
  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(is_revealed: false)
     |> assign(result: nil)
     |> assign(current_scratch_card: nil)
     |> push_event("clear-card", %{})}
  end

  @impl true
  def handle_info({"is_active", value}, socket) do
    {:noreply, socket |> assign(:scratch_card_active?, value)}
  end

  @impl true
  def handle_info({"price", value}, socket) do
    {:noreply, socket |> assign(:scratch_card_price, value)}
  end

  @impl true
  def handle_info({"drops", drops}, socket) do
    {:noreply, socket |> assign(:drops, drops)}
  end

  @impl true
  def handle_info({"win", value}, socket) do
    winning_user = value.attendee.user_id
    current_user = socket.assigns.current_user

    if winning_user != current_user.id do
      {:noreply,
       socket
       |> assign(:latest_wins, merge_wins(socket.assigns.latest_wins, value))}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp can_scratch?(scratch_card_active?, tokens, price, is_scratching?) do
    !is_scratching? && scratch_card_active? && tokens >= price
  end

  defp merge_wins(latest_wins, new_win) do
    ([new_win] ++ latest_wins)
    |> Enum.take(@max_wins)
  end
end
