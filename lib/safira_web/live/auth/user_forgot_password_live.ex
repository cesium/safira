defmodule SafiraWeb.UserForgotPasswordLive do
  use SafiraWeb, :landing_view

  alias Safira.Accounts

  import SafiraWeb.Components.Button

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm my-32 px-4">
      <.header class="text-center">
        Forgot your password?
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input
          field={@form[:email]}
          type="email"
          placeholder="john.doe@cesium.pt"
          label="Email"
          required
        />
        <:actions>
          <.action_button
            title={gettext("Send password reset instructions")}
            title_class="text-lg !font-iregular !normal-case"
            class="!h-14"
          />
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-8">
        <.link href={~p"/users/register"} class="hover:underline">Register</.link>
        | <.link href={~p"/users/log_in"} class="hover:underline">Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
