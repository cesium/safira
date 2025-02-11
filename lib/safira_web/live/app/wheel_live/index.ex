defmodule SafiraWeb.App.WheelLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.App.WheelLive.Components.ResultModal
  import SafiraWeb.App.WheelLive.Components.Wheel

  alias Safira.{Contest, Minigames}

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_user.attendee.ineligible do
      {:ok,
       socket
       |> put_flash(:error, "Can't play the wheel minigame with this account.")
       |> push_navigate(to: ~p"/app")}
    else
      if connected?(socket) do
        Minigames.subscribe_to_wheel_config_update("price")
        Minigames.subscribe_to_wheel_config_update("is_active")
      end

      {:ok,
       socket
       |> assign(:current_page, :wheel)
       |> assign(:in_spin?, false)
       |> assign(:attendee_tokens, socket.assigns.current_user.attendee.tokens)
       |> assign(:wheel_price, Minigames.get_wheel_price())
       |> assign(:result, nil)
       |> assign(:wheel_active?, Minigames.wheel_active?())}
    end
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

  def handle_event("get-prize", _params, socket) do
    case Minigames.spin_wheel(socket.assigns.current_user.attendee) do
      {:ok, type, drop} ->
        {:noreply,
         socket
         |> assign(:result, %{type: type, drop: drop})
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
         )
         # Reset wheel
         |> assign(:in_spin?, false)}

      {:error, message} ->
        {:noreply,
         socket
         |> assign(:in_spin?, false)
         # Restore attendee tokens if the spin fails
         |> assign(:attendee_tokens, socket.assigns.attendee_tokens + socket.assigns.wheel_price)
         |> put_flash(:error, message)}
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
  def handle_info({"is_active", value}, socket) do
    {:noreply, socket |> assign(:wheel_active?, value)}
  end

  defp can_spin?(wheel_active?, tokens, price, in_spin?) do
    !in_spin? && wheel_active? && tokens >= price
  end
end
