defmodule SafiraWeb.App.BadgeLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest
  import SafiraWeb.App.BadgeLive.Components.BadgeFilter
  import SafiraWeb.Components.Badge
  import SafiraWeb.Components.SearchBar

  @badge_page_size 18

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Contest.subscribe_to_attendee_redeems_update(socket.assigns.current_user.attendee.id)
    end

    {:ok, attendee_redeems, next_cursor, has_more} =
      Contest.list_attendee_badgedex_badges(
        socket.assigns.current_user.attendee.id,
        "",
        false,
        limit: @badge_page_size
      )

    {:ok,
     socket
     |> assign(:current_page, :badges)
     |> assign(:selection, :all)
     |> stream(:badges, attendee_redeems)
     |> assign(:search_query, "")
     |> assign(:badges_cursor, next_cursor)
     |> assign(:badges_has_more, has_more)
     |> assign(:loading_more_badges, false)}
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

  def handle_event("load-more-badges", _, socket) do
    if socket.assigns.badges_has_more and not socket.assigns.loading_more_badges do
      socket
      |> assign(:loading_more_badges, true)
      |> load_more_badges()
    else
      {:noreply, socket}
    end
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
           only_owned,
           limit: @badge_page_size
         ) do
      {:ok, badges, next_cursor, has_more} ->
        {:noreply,
         socket
         |> stream(:badges, badges, reset: true)
         |> assign(:badges_cursor, next_cursor)
         |> assign(:badges_has_more, has_more)
         |> assign(:loading_more_badges, false)}
    end
  end

  defp load_more_badges(socket) do
    attendee_id = socket.assigns.current_user.attendee.id
    only_owned = socket.assigns.selection == :redeemed

    case Contest.list_attendee_badgedex_badges(
           attendee_id,
           socket.assigns.search_query,
           only_owned,
           limit: @badge_page_size,
           after: socket.assigns.badges_cursor
         ) do
      {:ok, badges, next_cursor, has_more} ->
        {:noreply,
         socket
         |> stream(:badges, badges, at: -1)
         |> assign(:badges_cursor, next_cursor)
         |> assign(:badges_has_more, has_more)
         |> assign(:loading_more_badges, false)}
    end
  end
end
