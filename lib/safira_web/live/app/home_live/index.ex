defmodule SafiraWeb.App.HomeLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest

  @impl true
  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   Contest.subscribe_to_attendee_redeems_update(socket.assigns.current_user.attendee.id)
    # end

    # TODO: When the badgedex is ready, set the companies_visited based on the current_user info
    checkpoint_badges =
      Contest.list_badges(where: [is_checkpoint: true], order_by: [asc: :entries])

    attendee_badges = Contest.list_attendee_badges(socket.assigns.current_user.attendee.id)
    attendee_checkpoints = attendee_badges |> Enum.filter(& &1.is_checkpoint)

    companies_visited = 5
    max_level = length(checkpoint_badges)
    # max_level = 4
    # user_level = min(div(companies_visited, 5), max_level)
    user_level = min(length(attendee_checkpoints), max_level)

    companies_to_next_level =
      if user_level == max_level, do: 0, else: 5 - rem(companies_visited, 5)

    prizes_by_next_level = [10, 20, 40, 100]
    next_prize = Enum.at(prizes_by_next_level, user_level)

    {:ok,
     assign(socket,
       checkpoint_badges: checkpoint_badges,
       user_level: user_level,
       companies_to_next_level: companies_to_next_level,
       attendee_badge_count: length(attendee_badges),
       next_prize: next_prize,
       max_level: max_level
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _) do
    socket
    |> assign(:page_title, "Profile")
  end

  defp apply_action(socket, :edit, _) do
    socket
    |> assign(:page_title, "Edit Profile")
    |> assign(:attendee, socket.assigns.current_user.attendee)
  end
end
