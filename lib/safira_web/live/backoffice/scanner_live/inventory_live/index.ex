defmodule SafiraWeb.Backoffice.ScannerLive.InventoryLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Accounts

  import SafiraWeb.Components.Tabs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="-translate-y-4 sm:translate-y-0">
        <.tabs class="sm:hidden mb-4">
          <.link patch={~p"/dashboard/scanner"} class="w-full">
            <.tab class="gap-2">
              <.icon name="hero-check-badge" />
              {gettext("Badges")}
            </.tab>
          </.link>
          <.tab active class="gap-2">
            <.icon name="hero-gift" />
            {gettext("Redeems")}
          </.tab>
        </.tabs>
        <.page title={gettext("Attendee Redeems")}>
          <div
            id="qr-scanner"
            phx-hook="QrScanner"
            data-ask_perm="permission-button"
            data-open_on_mount
            data-on_start="document.getElementById('scan-info').style.display = 'none'"
            data-on_success="scan"
            class="relative"
          >
          </div>
          <div id="scan-info" class="flex flex-col items-center gap-8 text-center py-40">
            <p id="loadingMessage">
              {gettext("Unable to access camera.")}
              {gettext(
                "Make sure you allow the use of your camera on this browser and that it isn't being used elsewhere."
              )}
            </p>
            <.button id="permission-button" type="button">
              {gettext("Request Permission")}
            </.button>
          </div>
        </.page>
      </div>
      <.modal
        :if={@modal_data != nil}
        id="modal-scan-error"
        show
        on_cancel={JS.push("close-modal")}
        wrapper_class="px-4"
      >
        <div class="flex flex-row gap-4 items-center">
          <.icon name="hero-x-circle" class="text-red-500 w-8" />
          <p>
            <%= if @modal_data do %>
              {error_message(@modal_data)}
            <% end %>
          </p>
        </div>
      </.modal>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_page, :scanner)
     |> assign(:modal_data, nil)}
  end

  @impl true
  def handle_event("scan", data, socket) do
    case safely_extract_id_from_url(data) do
      {:ok, id} -> check_credential(id, socket)
      {:error, _} -> {:noreply, assign(socket, :modal_data, :invalid)}
    end
  end

  defp check_credential(id, socket) do
    if Accounts.credential_exists?(id) do
      handle_attendee_lookup(id, socket)
    else
      {:noreply, assign(socket, :modal_data, :not_found)}
    end
  end

  defp handle_attendee_lookup(id, socket) do
    case Accounts.get_attendee_from_credential(id) do
      nil ->
        {:noreply, assign(socket, :modal_data, :not_linked)}

      attendee ->
        {:noreply, push_navigate(socket, to: ~p"/dashboard/scanner/redeems/#{attendee.id}")}
    end
  end

  defp error_message(:not_found),
    do: gettext("This credential is not registered in the event's system! (404)")

  defp error_message(:not_linked),
    do: gettext("This credential is not linked to any attendee! (400)")

  defp error_message(:invalid), do: gettext("Not a valid credential! (400)")
end
