defmodule SafiraWeb.Backoffice.ScannerLive.EnrolmentLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.{Accounts, Activities, Contest}

  import SafiraWeb.Components.Tabs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="-translate-y-4 sm:translate-y-0">
        <.page>
          <div class="absolute flex justify-center inset-0 z-10 top-20 select-none">
            <span class="bg-dark text-light dark:bg-light dark:text-dark py-4 px-6 rounded-full font-semibold text-xl h-min">
              <%= gettext("Checking enrolments for %{activity_name}", activity_name: @activity.title) %>
            </span>
          </div>
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
              <%= gettext("Unable to access camera.") %>
              <%= gettext(
                "Make sure you allow the use of your camera on this browser and that it isn't being used elsewhere."
              ) %>
            </p>
            <.button id="permission-button" type="button">
              <%= gettext("Request Permission") %>
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
              <%= error_message(@modal_data) %>
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
     |> assign(:modal_data, nil)
     |> assign(:given_list, [])}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    activity = Activities.get_activity!(id)
    {:noreply, socket |> assign(:activity, activity)}
  end

  @impl true
  def handle_event("scan", data, socket) do
    case safely_extract_id_from_url(data) do
      {:ok, id} -> process_scan(id, socket)
      {:error, _} -> {:noreply, assign(socket, :modal_data, :invalid)}
    end
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, socket |> assign(:modal_data, nil)}
  end

  defp process_scan(id, socket) do
    if id in socket.assigns.given_list do
      {:noreply, socket}
    else
      check_credential(id, socket)
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
        handle_enrol_check(
          %{
            activity_id: socket.assigns.activity.id,
            attendee_id: attendee.id,
            credential_id: id
          },
          socket
        )
    end
  end

  defp handle_enrol_check(
         %{activity_id: activity_id, attendee_id: attendee_id, credential_id: credential_id},
         socket
       ) do
    if Activities.attendee_enrolled?(activity_id, attendee_id) do
      {:noreply,
       socket
       |> assign(:modal_data, nil)
       |> assign(:given_list, [credential_id | socket.assigns.given_list])}
    else
      {:noreply,
       socket
       |> assign(:modal_data, :not_enrolled)}
    end
  end

  defp error_message(:not_enrolled),
    do: gettext("Attendee not enrolled! (404)")

  defp error_message(:not_found),
    do: gettext("This credential is not registered in the event's system! (404)")

  defp error_message(:not_linked),
    do: gettext("This credential is not linked to any attendee! (400)")

  defp error_message(:invalid), do: gettext("Not a valid credential! (400)")
end
