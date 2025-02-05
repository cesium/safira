defmodule SafiraWeb.App.SlotsLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.App.SlotsLive.Components.ResultModal
  import SafiraWeb.App.SlotsLive.Components.Machine
  import SafiraWeb.App.SlotsLive.Components.PaytableModal

  alias Safira.Minigames

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Minigames.subscribe_to_slots_config_update("is_active")
    end

    {:ok,
     socket
     |> assign(:current_page, :slots)
     |> assign(:in_spin?, false)
     |> assign(:attendee_tokens, socket.assigns.current_user.attendee.tokens)
     |> assign(:result, nil)
     |> assign(:bet, 10)
     |> assign(:slots_active?, Minigames.slots_active?())}
  end

  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:result, nil)}
  end

  def handle_event("spin-slots", _params, socket) do
    if socket.assigns.bet <= 0 do
      {:noreply,
       socket
       |> put_flash(:error, gettext("Please set a bet amount greater than 0."))}
    else
      case Minigames.spin_slots(socket.assigns.current_user.attendee, socket.assigns.bet) do
        {:ok, target, multiplier, attendee_tokens, winnings} ->
          {:noreply,
           socket
           |> assign(:in_spin?, true)
           |> assign(:result, %{
             multiplier: multiplier,
             target: target,
             new_attendee_tokens: attendee_tokens,
             winnings: winnings
           })
           |> assign(:attendee_tokens, socket.assigns.attendee_tokens - socket.assigns.bet)
           |> push_event("roll_reels", %{target: target})}

        {:error, message} ->
          {:noreply,
           socket
           |> assign(:in_spin?, false)
           |> assign(:attendee_tokens, socket.assigns.attendee_tokens + socket.assigns.bet)
           |> put_flash(:error, message)}
      end
    end
  end

  @impl true
  def handle_event("roll_complete", _params, socket) do
    {:noreply,
     socket
     |> assign(:in_spin?, false)
     |> assign(:attendee_tokens, socket.assigns.result.new_attendee_tokens)}
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
  def handle_info({"is_active", value}, socket) do
    {:noreply, socket |> assign(:slots_active?, value)}
  end
end
