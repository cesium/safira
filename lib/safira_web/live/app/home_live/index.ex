defmodule SafiraWeb.App.HomeLive.Index do
  use SafiraWeb, :app_view

  @impl true
  def mount(_params, _session, socket) do
    # TODO: When the badgedex is ready, set the companies_visited based on the current_user info
    companies_visited = 14
    max_level = 4
    user_level = min(div(companies_visited, 5), max_level)
    companies_to_next_level = if user_level == max_level, do: 0, else: 5 - rem(companies_visited, 5)

    prizes_by_next_level = [10, 20, 40, 100]
    next_prize = Enum.at(prizes_by_next_level, user_level)

    {:ok,
     assign(socket,
      companies_visited: companies_visited,
      user_level: user_level,
      companies_to_next_level: companies_to_next_level,
      next_prize: next_prize,
      max_level: max_level
     )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
