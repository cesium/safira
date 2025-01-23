defmodule SafiraWeb.Backoffice.ScannerLive.BadgeLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Contest

  @impl true
  def render(assigns) do
    ~H"""
    <.page>
      <div class="absolute flex justify-center inset-0 z-10 top-20 select-none">
        <span class="bg-dark text-light dark:bg-light dark:text-dark py-4 px-6 rounded-full font-semibold text-xl h-min">
          <%= gettext("Giving badge %{badge_name}", badge_name: @badge.name) %>
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
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :scanner)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply, socket |> assign(:badge, Contest.get_badge!(id))}
  end
end
