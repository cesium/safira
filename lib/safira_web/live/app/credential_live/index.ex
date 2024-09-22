defmodule SafiraWeb.App.CredentialLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_, _, socket) do
    credential = Accounts.get_credential_of_attendee!(socket.assigns.current_user.attendee)
    {:noreply, socket |> push_navigate(to: ~p"/app/credential/#{credential.id}")}
  end
end
