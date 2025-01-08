defmodule SafiraWeb.UserUpdateEmailConfirmation do
  use SafiraWeb, :live_view

  alias Safira.Accounts

  def mount(%{"token" => token}, _session, socket) do
    user = socket.assigns.current_user

    socket =
      case Accounts.update_user_email(user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    base_path =
      if user.type == :attendee do
        "app"
      else
        "dashboard"
      end

    {:ok,
     socket
     |> assign(base_path: base_path)
     |> push_navigate(to: ~p"/#{base_path}/profile_settings")
    }
  end
end
