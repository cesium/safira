defmodule SafiraWeb.Backoffice.BadgeLive.RedeemLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Contest

  import SafiraWeb.Components.{Table, TableSearch}

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
              id="attendees-table-name-search"
              params={@params}
              field={:name}
              path={~p"/dashboard/badges/#{@badge.id}/redeems"}
              placeholder={gettext("Search for attendees")}
            />
          </div>
        </:actions>
        <.table id="speakers-table" items={@streams.redeems} meta={@meta} params={@params}>
          <:col :let={{_id, redeem}} field={:name} label="Attendee">
            <div class="flex gap-4 flex-center items-center">
              <.avatar
                src={
                  Uploaders.UserPicture.url(
                    {redeem.attendee.user.picture, redeem.attendee.user},
                    :original,
                    signed: true
                  )
                }
                handle={redeem.attendee.user.handle}
              />
              <div class="self-center">
                <p class="text-base font-semibold"><%= redeem.attendee.user.name %></p>
                <p class="font-normal truncate max-w-[12rem]"><%= redeem.attendee.user.handle %></p>
              </div>
            </div>
          </:col>
          <:col :let={{_id, redeem}} field={:redeemed_by} label="Redeemed by">
            <%= if redeem.redeemed_by, do: redeem.redeemed_by.user.name, else: "System / Company" %>
          </:col>
          <:col :let={{_id, redeem}} sortable field={:inserted_at} label="Redeemed at">
            <%= datetime_to_string(redeem.inserted_at) %>
          </:col>
          <:action :let={{id, redeem}}>
            <div class="flex flex-row gap-2">
              <.link
                phx-click={
                  JS.push("delete", value: %{id: redeem.id}, target: @myself) |> hide("##{id}")
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
    case Contest.list_badge_redeems_meta(
           assigns.badge.id,
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
