defmodule SafiraWeb.App.BadgeLive.Show do
  use SafiraWeb, :app_view

  alias Safira.Contest
  import SafiraWeb.Components.Badge

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Contest.subscribe_to_attendee_redeems_update(socket.assigns.current_user.attendee.id)
    end

    badge = Contest.get_badge!(id)

    {:ok,
     socket
     |> assign(:current_page, :badges)
     |> assign(:badge, badge)
     |> assign(
       :owns_badge,
       Contest.attendee_owns_badge?(socket.assigns.current_user.attendee.id, badge.id)
     )
     |> assign(:owners_count, Contest.count_badge_redeems(badge.id))
     |> stream(
       :owners,
       Contest.list_badge_redeems(badge.id, order_by: [desc: :inserted_at], limit: 5)
     )}
  end

  @impl true
  def handle_info(redeem, socket) do
    if redeem.badge_id == socket.assigns.badge.id do
      {:noreply,
       socket
       |> assign(:owns_badge, true)
       |> assign(:owners_count, socket.assigns.owners_count + 1)
       |> stream_insert(
         :owners,
         Map.put(
           redeem,
           :attendee,
           Map.put(socket.assigns.current_user.attendee, :user, socket.assigns.current_user)
         ),
         at: 0
       )}
    else
      {:noreply, socket}
    end
  end
end
