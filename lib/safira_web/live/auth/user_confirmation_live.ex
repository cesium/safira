defmodule SafiraWeb.UserConfirmationLive do
  use SafiraWeb, :landing_view

  import SafiraWeb.Components.Button

  alias Safira.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div
      id="user-email-confirmed"
      phx-hook="Redirect"
      class="mx-auto max-w-lg py-12 flex flex-col items-center"
    >
      <div class="w-full flex items-center justify-center">
        <span class="ring-2 sm:ring-4 ring-white rounded-full p-4 sm:p-6">
          <.icon name="hero-check" class="w-10 h-10 sm:w-16 sm:h-16" />
        </span>
      </div>
      <h1 class="px-4 font-terminal uppercase text-3xl text-center mt-8 sm:mt-10">
        <%= gettext("Email address has been verified!") %>
      </h1>
      <p class="text-center mt-6 px-4">
        <%= gettext("Your account has been activated successfully.") %>
      </p>
      <p class="text-center mt-4 px-4">
        <%= gettext("Redirecting you to the app...") %>
      </p>
      <.link
        navigate={~p"/app"}
        class="text-sm sm:text-md text-center mt-8 opacity-80 px-4 hover:underline"
      >
        <%= gettext("Not working? Click here.") %>
      </.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"token" => token}, _url, socket) do
    confirm_account(token, socket)
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def confirm_account(token, socket) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "User confirmed successfully.")
         |> push_event("redirect", %{url: ~p"/app", time: 1200})}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, push_event(socket, "redirect", %{url: ~p"/", time: 1200})}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> push_event("redirect", %{url: ~p"/app", time: 1200})}
        end
    end
  end
end
