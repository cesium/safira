defmodule SafiraWeb.App.UserLive.Show do
  use SafiraWeb, :app_view

  alias Safira.Accounts
  alias Safira.Contest

  import SafiraWeb.Components.Badge

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"handle" => handle}, _, socket) do
    user = Accounts.get_user_by_handle!(handle)

    page_title = if user.type == "attendee", do: "Attendee", else: "User"

    attendee_id = user.attendee.id

    if connected?(socket) do
      Contest.subscribe_to_attendee_redeems_update(attendee_id)
    end

    attendee = user.attendee

    attendee_badge_reddeems =
      Contest.list_attendee_all_badges_redeem_status(
        attendee_id,
        true
      )

    {:noreply,
     socket
     |> assign(:page_title, page_title)
     |> assign(:attendee, attendee)
     |> assign(:user, user)
     |> assign(attendee_badge_count: length(attendee_badge_reddeems))
     |> stream(:attendee_badge_redeems, attendee_badge_reddeems |> Enum.take(5))
     |> assign(attendee_tokens: attendee.tokens)
     |> assign(attendee_entries: attendee.entries)}
  end

  @impl true
  def handle_info(redeem, socket) do
    user_level =
      if redeem.badge.is_checkpoint,
        do: socket.assigns.user_level + 1,
        else: socket.assigns.user_level

    {:noreply,
     socket
     |> stream_insert(
       :attendee_badge_redeems,
       Map.put(redeem.badge, :redeemed_at, redeem.inserted_at),
       at: 0,
       limit: 5
     )
     |> assign(user_level: user_level)
     |> assign(attendee_badge_count: socket.assigns.attendee_badge_count + 1)
     |> assign(attendee_tokens: socket.assigns.attendee_tokens + redeem.badge.tokens)
     |> assign(attendee_entries: socket.assigns.attendee_entries + redeem.badge.entries)}
  end
end
