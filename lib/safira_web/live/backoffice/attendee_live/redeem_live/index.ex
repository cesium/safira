defmodule SafiraWeb.Backoffice.AttendeeLive.RedeemLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Contest

  import SafiraWeb.Components.{Badge, Table, TableSearch}

  on_mount {SafiraWeb.StaffRoles, index: %{"badges" => ["revoke"]}}

  @limit 5

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Refund badge redeems.")}>
        <:actions>
          <div class="flex flex-row w-full gap-4">
            <.table_search
              id="badges-table-name-search"
              params={@params}
              field={:name}
              path={~p"/dashboard/attendees/#{@attendee.id}/redeem"}
              placeholder={gettext("Search for badges")}
            />
          </div>
        </:actions>
        <.table id="speakers-table" items={@streams.redeems} meta={@meta} params={@params}>
          <:col :let={{_id, redeem}} field={:badge} label="Badge">
            <.badge id={redeem.badge.id} badge={redeem.badge} width="max-w-16" />
            <div class="flex gap-4 flex-center max-w-16"></div>
          </:col>
          <:col :let={{_id, redeem}} field={:redeemed_by} label="Redeemed by">
            {if redeem.redeemed_by, do: redeem.redeemed_by.user.name, else: "System / Company"}
          </:col>
          <:col :let={{_id, redeem}} sortable field={:inserted_at} label="Redeemed at">
            {datetime_to_string(redeem.inserted_at)}
          </:col>
          <:action :let={{id, speaker}}>
            <div class="flex flex-row gap-2">
              <.link
                phx-click={
                  JS.push("delete", value: %{id: speaker.id}, target: @myself) |> hide("##{id}")
                }
                data-confirm="Are you sure?"
              >
                <.icon name="hero-trash" class="w-5 h-5" />
              </.link>
            </div>
          </:action>
        </.table>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    case Contest.list_attendee_redeems_meta(
           assigns.attendee.id,
           Map.put(assigns.params, "page_size", @limit)
         ) do
      {:ok, {redeems, meta}} ->
        {:ok,
         socket
         |> assign(assigns)
         |> assign(meta: meta)
         |> stream(
           :redeems,
           redeems,
           reset: true
         )}

      {:error, _error} ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    badge_redeem = Contest.get_badge_redeem!(id)

    case Contest.revoke_badge_redeem_from_attendee(id) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :redeems, badge_redeem)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  defp datetime_to_string(datetime) do
    Timex.format!(datetime, "%D %T", :strftime)
  end
end
