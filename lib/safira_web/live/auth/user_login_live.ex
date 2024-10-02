defmodule SafiraWeb.UserLoginLive do
  use SafiraWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <div class="px-32 py-12">
        <img class="w-full h-full block" src={~p"/images/sei.svg"} />
      </div>

      <.header class="text-center">
        Log in to account
        <:subtitle>
          <%= if @registrations_open do %>
            Don't have an account?
            <.link navigate={~p"/users/register"} class="font-semibold text-primary hover:underline">
              Sign up
            </.link>
            for an account now.
          <% end %>
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form) |> assign(registrations_open: registrations_open?()),
     temporary_assigns: [form: form]}
  end
end
