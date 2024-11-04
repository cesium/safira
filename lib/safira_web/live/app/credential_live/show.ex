defmodule SafiraWeb.App.CredentialLive.Show do
  use SafiraWeb, :app_view

  alias Safira.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    credential = Accounts.get_credential!(id, [:attendee])

    # QR Code not yet assigned
    if is_nil(credential.attendee) do
      # User is not an attendee, show nothing
      # User is an attendee, redirect to assigning page
      if is_nil(socket.assigns.current_user.attendee.id) do
        {:noreply,
         socket
         |> push_navigate(to: "/404", replace: true)}
      else
        {:noreply,
         socket
         |> push_navigate(to: ~p"/app/credential/#{credential.id}/edit", replace: true)}
      end
    else
      # Current user is the attendee which the QR Code belongs to, display
      # the QR code
      # Redirect to the user profile
      if credential.attendee_id == socket.assigns.current_user.attendee.id do
        {:noreply,
         socket
         |> assign(:page_title, "Show QR Code")
         |> assign(:credential, credential)}
      else
        {:noreply,
         socket
         |> push_navigate(to: "/attendees/#{credential.attendee_id}", replace: true)}
      end
    end
  end
end
