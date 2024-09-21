defmodule SafiraWeb.App.CredentialLive.Edit do
  use SafiraWeb, :app_view

  alias Safira.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    credential = Accounts.get_credential!(id, [:attendee])

    if is_nil(credential.attendee) do
      {:noreply, socket |> assign(credential: credential)}
    else
      {:noreply, socket |> push_navigate(to: ~p"/app/credential/#{credential.id}")}
    end
  end

  @impl true
  def handle_event("claim", _, socket) do
    socket.assigns.credential
    |> Accounts.update_credential(%{attendee_id: socket.assigns.current_user.attendee.id})
    |> case do
      {:ok, _credential} ->
        {:noreply,
         socket
         |> put_flash(:info, "Credential claimed successfully")
         |> push_navigate(to: ~p"/app/")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Unable to claim credential. Try again later")}
    end
  end
end
