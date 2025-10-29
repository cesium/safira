defmodule SafiraWeb.UserLoginLive do
  use SafiraWeb, :landing_view

  alias Safira.Event

  import SafiraWeb.Components.Button

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm px-4 py-2">
      <div class="px-24 sm:px-20 py-6 sm:py-12">
        <img class="w-full h-full block" src={~p"/images/star-struck-void.svg"} />
      </div>

      <.header class="text-center">
        Log in to account
        <:subtitle>
          <%= if @registrations_open do %>
            Don't have an account?
            <.link navigate={~p"/users/register"} class="font-semibold text-accent hover:underline">
              Sign up
            </.link>
            for an account now.
          <% end %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="login_form"
        action={
          ~p"/users/log_in?action=#{@action || ""}&action_id=#{@action_id || ""}&return_to=#{@return_to || ""}"
        }
        phx-update="ignore"
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <div class="flex items-center">
            <div class="mr-1 pr-2">
              <.input field={@form[:remember_me]} type="checkbox" />
            </div>
            <div class="inline text-sm">
              {gettext("Keep me logged in.")}
            </div>
          </div>
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.action_button title="Log in" class="w-full mt-6" />
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     assign(socket, form: form)
     |> assign(registrations_open: Event.registrations_open?())
     |> assign(:action_id, Map.get(params, "action_id"))
     |> assign(:action, Map.get(params, "action"))
     |> assign(:return_to, Map.get(params, "return_to")), temporary_assigns: [form: form]}
  end
end
