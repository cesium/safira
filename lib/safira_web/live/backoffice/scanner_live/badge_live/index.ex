defmodule SafiraWeb.Backoffice.ScannerLive.BadgeLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.{Accounts, Contest}

  import SafiraWeb.Components.Tabs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="-translate-y-4 sm:translate-y-0">
        <.tabs class="sm:hidden mb-4">
          <.link patch={~p"/dashboard/scanner"} class="w-full">
            <.tab active class="gap-2">
              <.icon name="hero-check-badge" />
              {gettext("Badges")}
            </.tab>
          </.link>
          <.link patch={~p"/dashboard/scanner/redeems"} class="w-full">
            <.tab class="gap-2">
              <.icon name="hero-gift" />
              {gettext("Redeems")}
            </.tab>
          </.link>
        </.tabs>
        <.page>
          <div class="absolute flex justify-center inset-0 z-10 top-20 select-none">
            <span class="bg-dark text-light dark:bg-light dark:text-dark py-4 px-6 rounded-full font-semibold text-xl h-min">
              {gettext("Giving badge %{badge_name}", badge_name: @badge.name)}
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
     |> assign(:modal_data, nil)
     |> assign(:given_list, [])}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    badge = Contest.get_badge!(id)

    if can_redeem_badge?(socket |> assign(:badge, badge)) do
      {:noreply, socket |> assign(:badge, badge)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "This badge is not currently available for redemption.")
       |> push_navigate(to: ~p"/dashboard/scanner")}
    end
  end

  @impl true
  def handle_event("scan", data, socket) do
    if can_redeem_badge?(socket) do
      case safely_extract_id_from_url(data) do
        {:ok, id} -> process_scan(id, socket)
        {:error, _} -> {:noreply, assign(socket, :modal_data, :invalid)}
      end
    else
      {:noreply, assign(socket, :modal_data, :out_of_time)}
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
        handle_redeem_badge(
          %{
            badge_id: socket.assigns.badge.id,
            attendee: attendee,
            staff: socket.assigns.current_user.staff,
            credential_id: id
          },
          socket
        )
    end
  end

  defp handle_redeem_badge(
         %{badge_id: badge_id, attendee: attendee, staff: staff, credential_id: credential_id},
         socket
       ) do
    badge = Contest.get_badge!(badge_id)

    case Contest.redeem_badge(badge, attendee, staff) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:modal_data, nil)
         |> assign(:given_list, [credential_id | socket.assigns.given_list])}

      {:error, "attendee already has this badge"} ->
        {:noreply,
         socket
         |> assign(:modal_data, :already_redeemed)
         |> assign(:given_list, [credential_id | socket.assigns.given_list])}

      {:error, _} ->
        {:noreply, socket |> assign(:modal_data, :not_linked)}
    end
  end

  defp error_message(:already_redeemed),
    do: gettext("Attendee already has this badge! (400)")

  defp error_message(:not_found),
    do: gettext("This credential is not registered in the event's system! (404)")

  defp error_message(:not_linked),
    do: gettext("This credential is not linked to any attendee! (400)")

  defp error_message(:invalid), do: gettext("Not a valid credential! (400)")

  defp error_message(:out_of_time),
    do: gettext("This badge is not currently available for redemption! (400)")

  defp can_redeem_badge?(socket) do
    now = DateTime.utc_now()

    user_can_bypass_badge_restrictions?(socket) or
      (DateTime.compare(now, socket.assigns.badge.begin) == :gt and
         DateTime.compare(now, socket.assigns.badge.end) == :lt and socket.assigns.badge.givable)
  end

  defp user_can_bypass_badge_restrictions?(socket) do
    permissions = socket.assigns.current_user.staff.role.permissions

    Map.has_key?(permissions, "badges") and
      Map.get(permissions, "badges") |> Enum.member?("give_without_restrictions")
  end
end
