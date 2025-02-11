defmodule SafiraWeb.AttendeeLive.Index do
  use SafiraWeb, :live_view

  alias Safira.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"credential_id" => credential_id}, _uri, socket) do
    case Accounts.get_attendee_from_credential(credential_id, [:user]) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Attendee not found")
         |> redirect(to: ~p"/")}

      attendee ->
        # Get base path based on user type
        path =
          if socket.assigns.current_user.type == :attendee do
            ~p"/app/user/#{attendee.user.handle}"
          else
            ~p"/dashboard/attendees/#{attendee.id}"
          end

        {:noreply,
         socket
         |> redirect(to: path)}
    end
  end
end
