defmodule SafiraWeb.App.BadgeLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest
  import SafiraWeb.App.BadgeLive.Components.BadgeFilter
  import SafiraWeb.Components.Badge
  import SafiraWeb.Components.SearchBar

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
     |> stream(:badges, attendee_redeems)
     |> assign(:search_query, "")}
  end

  @impl true
  def handle_event("set-selection", %{"selection" => "all"}, socket) do
    socket
    |> assign(:selection, :all)
    |> reload_badges()
  end

  def handle_event("set-selection", %{"selection" => "redeemed"}, socket) do
    socket
    |> assign(:selection, :redeemed)
    |> reload_badges()
  end

  def handle_event("set-selection", _, socket) do
    {:noreply, socket}
  end

  def handle_event("update-search", %{"badge_search" => search_term}, socket) do
    socket
    |> assign(:search_query, search_term)
    |> reload_badges()
  end

  @impl true
  def handle_info(redeem, socket) do
    {:noreply,
     socket
     |> stream_delete(:badges, redeem.badge)
     |> stream_insert(:badges, Map.put(redeem.badge, :redeemed_at, redeem.inserted_at), at: 0)}
  end

  defp reload_badges(socket) do
    attendee_id = socket.assigns.current_user.attendee.id
    only_owned = socket.assigns.selection == :redeemed

    case Contest.list_attendee_badgedex_badges(
           attendee_id,
           socket.assigns.search_query,
           only_owned
         ) do
      {:ok, badges} ->
        {:noreply, stream(socket, :badges, badges, reset: true)}

      {:error, _meta} ->
        {:noreply, socket}
    end
  end
end
