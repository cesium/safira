defmodule SafiraWeb.App.BadgeLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest
  import SafiraWeb.Components.Badge

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Contest.subscribe_to_attendee_redeems_update(socket.assigns.current_user.attendee.id)
    end

    attendee_redeems =
      Contest.list_attendee_all_badges_redeem_status(socket.assigns.current_user.attendee.id)

    {:ok,
     socket
     |> assign(:current_page, :badges)
     |> assign(:selection, :all)
     |> stream(:badges, attendee_redeems)}
  end

  @impl true
  def handle_event("swap-selection", _, socket) do
    case socket.assigns.selection do
      :all ->
        {:noreply,
         socket
         |> assign(:selection, :redeemed)
         |> stream(
           :badges,
           Contest.list_attendee_all_badges_redeem_status(
             socket.assigns.current_user.attendee.id,
             true
           ),
           reset: true
         )}

      :redeemed ->
        {:noreply,
         socket
         |> assign(:selection, :all)
         |> stream(
           :badges,
           Contest.list_attendee_all_badges_redeem_status(
             socket.assigns.current_user.attendee.id
           ),
           reset: true
         )}
    end
  end

  @impl true
  def handle_info(redeem, socket) do
    {:noreply,
     socket
     |> stream_delete(:badges, redeem.badge)
     |> stream_insert(:badges, Map.put(redeem.badge, :redeemed_at, redeem.inserted_at), at: 0)}
  end

  defp next_selection_text(selection) do
    case selection do
      :all -> gettext("Mine")
      :redeemed -> gettext("All")
    end
  end
end
