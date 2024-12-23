defmodule SafiraWeb.App.CredentialLive.Edit do
  use SafiraWeb, :app_view

  alias Safira.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket |> assign(:modal_data, nil)}
  end

  @impl true
  def handle_event("scan", data, socket) do
    case safely_extract_id_from_url(data) do
      {:ok, id} ->
        if Accounts.credential_exists?(id) do
          if Accounts.credential_linked?(id) do
            {:noreply, socket |> assign(:modal_data, :already_linked)}
          else
            Accounts.link_credential(id, socket.assigns.current_user.attendee.id)
            {:noreply, socket |> push_navigate(to: ~p"/app")}
          end
        else
          {:noreply, socket |> assign(:modal_data, :not_found)}
        end

      {:error, _} ->
        {:noreply, socket |> assign(:modal_data, :invalid)}
    end
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, socket |> assign(:modal_data, nil)}
  end

  def error_message(:not_found),
    do: gettext("This credential is not registered in the event's system! (404)")

  def error_message(:already_linked),
    do: gettext("This credential is already linked to another attendee! (400)")

  def error_message(:invalid), do: gettext("Not a valid credential! (400)")
end
