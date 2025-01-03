defmodule SafiraWeb.ConfirmationPendingLive do
  use SafiraWeb, :live_view

  alias Safira.Accounts

  import SafiraWeb.Components.Button

  @delay_between_emails 30

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <img class="w-52 h-52 m-auto block" src={~p"/images/sei.svg"} />
      <h1 class="font-terminal uppercase text-4xl sm:text-6xl text-center mt-24">
        Just one more step remaining!
      </h1>
      <p class="font-terminal text-xl sm:text-2xl text-center mt-4">
        <%= gettext(
          "We have sent you an email containing instructions on how to verify your account. Click the link in it to conclude your registration for SEI'25!"
        ) %>
      </p>
      <p class="font-terminal text-md sm:text-xl text-center mt-2">
        <%= gettext(
          "If you haven't received an email, check your Spam and Junk folders. If it is not there, click the button below to receive a new link."
        ) %>
      </p>
      <div
        id="seconds-remaining"
        class="font-terminal text-center text-2xl sm:text-4xl mt-12"
        phx-hook="Countdown"
      >
        <.action_button title={gettext("Re-send Verification Email")} phx-click="resend" />
      </div>
      <.link class="text-center block mt-8 underline" href="/users/log_out" method="delete">
        Sign out
      </.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:last_sent, nil)}
  end

  def handle_event("resend", _params, socket) do
    # To avoid sending many emails if a user decides to smash the resend button,
    # we only allow emails to be sent once every 30 seconds
    if throttle_socket?(socket) do
      {:noreply, socket}
    else
      Accounts.deliver_user_confirmation_instructions(
        socket.assigns.current_user,
        &url(~p"/users/confirm/#{&1}")
      )

      {:noreply,
       socket
       |> put_flash(:info, "The email has been sent to your inbox")
       |> assign(:last_sent, DateTime.utc_now())}
    end
  end

  defp throttle_socket?(socket) do
    not is_nil(socket.assigns.last_sent) and
      DateTime.diff(DateTime.utc_now(), socket.assigns.last_sent) < @delay_between_emails
  end
end
