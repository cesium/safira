defmodule SafiraWeb.App.HomeLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest

  import SafiraWeb.Components.Badge

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Contest.subscribe_to_attendee_redeems_update(socket.assigns.current_user.attendee.id)
    end

    checkpoint_badges =
      Contest.list_badges(where: [is_checkpoint: true], order_by: [asc: :entries])

    attendee_badges = Contest.list_attendee_badges(socket.assigns.current_user.attendee.id)
    attendee_checkpoints = attendee_badges |> Enum.filter(& &1.is_checkpoint)

    max_level = length(checkpoint_badges)
    user_level = min(length(attendee_checkpoints), max_level)

    attendee_badge_reddeems =
      Contest.list_attendee_all_badges_redeem_status(
        socket.assigns.current_user.attendee.id,
        true
      )

    {:ok,
     socket
     |> assign(
       current_page: :home,
       checkpoint_badges: checkpoint_badges,
       user_level: user_level,
       attendee_badge_count: length(attendee_badges),
       max_level: max_level,
       attendee_tokens: socket.assigns.current_user.attendee.tokens,
       attendee_entries: socket.assigns.current_user.attendee.entries
     )
     |> stream(:attendee_badge_redeems, attendee_badge_reddeems |> Enum.take(3))}
  end

  @impl true
  def handle_info(redeem, socket) do
    user_level =
      if redeem.badge.is_checkpoint,
        do: socket.assigns.user_level + 1,
        else: socket.assigns.user_level

    {:noreply,
     socket
     |> stream_insert(:attendee_badge_redeems, redeem.badge, at: 0, limit: 3)
     |> assign(user_level: user_level)
     |> assign(attendee_badge_count: socket.assigns.attendee_badge_count + 1)
     |> assign(attendee_tokens: socket.assigns.attendee_tokens + redeem.badge.tokens)
     |> assign(attendee_entries: socket.assigns.attendee_entries + redeem.badge.entries)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
