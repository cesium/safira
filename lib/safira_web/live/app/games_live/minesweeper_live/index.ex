defmodule SafiraWeb.App.GamesLive.MinesweeperLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Minigames

  import SafiraWeb.App.GamesLive.SlotsLive.Components.ResultModal

  @impl true
  def mount(_params, _session, socket) do
    attendee = socket.assigns.current_user.attendee

    if connected?(socket) do
      Minigames.subscribe_to_minesweeper_config_update("is_active")
    end

    {:ok,
     socket
     |> assign(:current_page, :minesweeper)
     |> assign(:attendee_tokens, attendee.tokens)
     |> assign(:bet, 10)
     |> assign(:mines, 3)
     |> assign(:min_mines, Minigames.minesweeper_min_mines())
     |> assign(:max_mines, Minigames.minesweeper_max_mines())
     |> assign_round(Minigames.continue_active_minesweeper_round(attendee.id))
     |> assign(:result, nil)
     |> assign(:minesweeper_active?, Minigames.minesweeper_active?())}
  end

  @impl true
  def handle_event("set-bet", %{"bet" => bet}, socket) do
    bet = parse_integer(bet, 0)

    {:noreply, socket |> assign(:bet, max(bet, 0))}
  end

  def handle_event("set-mines", %{"mines" => mines}, socket) do
    mines = parse_integer(mines, socket.assigns.mines)

    {:noreply,
     socket
     |> assign(
       :mines,
       mines |> max(Minigames.minesweeper_min_mines()) |> min(Minigames.minesweeper_max_mines())
     )}
  end

  def handle_event("start-game", _params, socket) do
    attendee = socket.assigns.current_user.attendee
    bet = socket.assigns.bet
    mines = socket.assigns.mines

    case Minigames.place_bet_minesweeper(attendee, bet, mines) do
      {:ok, game} ->
        {:noreply,
         socket
         |> assign_round(game)
         |> assign(:attendee_tokens, socket.assigns.attendee_tokens - bet)}

      {:error, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)}
    end
  end

  def handle_event("reveal", %{"position" => position}, socket) do
    attendee = socket.assigns.current_user.attendee

    case socket.assigns.game do
      nil ->
        {:noreply, socket}

      game ->
        case Minigames.reveal_minesweeper_tile(attendee, game.id, parse_integer(position, nil)) do
          {:ok, %{status: :cashed_out} = round} ->
            {:noreply, socket |> assign_cashout(round)}

          {:ok, round} ->
            {:noreply, socket |> assign_round(round)}

          {:error, message} ->
            {:noreply, socket |> put_flash(:error, message)}
        end
    end
  end

  def handle_event("cashout", _params, socket) do
    attendee = socket.assigns.current_user.attendee

    case socket.assigns.game do
      nil ->
        {:noreply, socket}

      game ->
        case Minigames.cashout_minesweeper_round(attendee, game.id) do
          {:ok, round} ->
            {:noreply, socket |> assign_cashout(round)}

          {:error, message} ->
            {:noreply, socket |> put_flash(:error, message)}
        end
    end
  end

  def handle_event("close-modal", _params, socket) do
    {:noreply, assign(socket, :result, nil)}
  end

  @impl true
  def handle_info({"is_active", value}, socket) do
    {:noreply, assign(socket, :minesweeper_active?, value)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  attr :position, :integer, required: true
  attr :state, :atom, required: true, values: [:hidden, :safe, :mine, :lost]
  attr :disabled, :boolean, default: false

  defp tile(assigns) do
    ~H"""
    <button
      phx-click="reveal"
      phx-value-position={@position}
      disabled={@disabled or @state != :hidden}
      class={[
        "flex items-center size-18 justify-center rounded-xl border transition-colors duration-300",
        tile_class(@state),
        @state == :hidden && !@disabled && "cursor-pointer hover:border-accent/60"
      ]}
    >
      <.icon :if={@state == :safe} name="fa-gem-solid" class="size-6 text-accent" />
      <.icon :if={@state in [:mine, :lost]} name="fa-bomb-solid" class="size-6 text-white" />
    </button>
    """
  end

  attr :rest, :global, include: ~w(disabled)
  slot :inner_block, required: true

  defp control_button(assigns) do
    ~H"""
    <button
      class="px-4 py-3 flex-none border min-w-15 cursor-pointer tracking-wider hover:border-accent/60 transition-colors duration-300 border-light/10 bg-light/5 active:bg-accent/60 active:text-primary rounded-xl font-bold disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:border-light/10"
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp tile_class(:hidden), do: "border-light/10 bg-light/5"
  defp tile_class(:safe), do: "border-accent/60 bg-accent/10"
  defp tile_class(:mine), do: "border-light/10 bg-light/5 opacity-50"
  defp tile_class(:lost), do: "border-red-500 bg-red-500/30"

  defp tile_state(nil, _position), do: :hidden

  defp tile_state(game, position) do
    revealed? = position in game.revealed_positions
    mine? = position in game.mine_positions

    cond do
      revealed? and mine? -> :lost
      revealed? -> :safe
      mine? and not Minigames.minesweeper_round_active?(game) -> :mine
      true -> :hidden
    end
  end

  defp assign_round(socket, nil) do
    socket
    |> assign(:game, nil)
    |> assign(:multiplier, 1.0)
    |> assign(:winnings, 0)
  end

  defp assign_round(socket, round) do
    case Minigames.minesweeper_round_active?(round) do
      true ->
        multiplier = Minigames.minesweeper_round_multiplier(round)

        socket
        |> assign(:game, round)
        |> assign(:bet, round.bet)
        |> assign(:mines, length(round.mine_positions))
        |> assign(:multiplier, Float.round(multiplier, 2))
        |> assign(:winnings, floor(round.bet * multiplier))

      _ ->
        socket
        |> assign(:game, round)
    end
  end

  defp parse_integer(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _ -> default
    end
  end

  defp parse_integer(_value, default), do: default

  defp assign_cashout(socket, round) do
    multiplier = Minigames.minesweeper_round_multiplier(round)

    socket
    |> assign(:result, %{multiplier: Float.round(multiplier, 2), winnings: round.tokens})
    |> assign(:attendee_tokens, socket.assigns.attendee_tokens + round.tokens)
    |> assign_round(nil)
  end
end
