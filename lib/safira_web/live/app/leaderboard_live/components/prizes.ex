defmodule SafiraWeb.App.LeaderboardLive.Components.Prizes do
  @moduledoc """
  Prizes component
  """

  use SafiraWeb, :component

  attr :prizes, :list, required: true

  def prizes(assigns) do
    ~H"""
    <ol>
      <%= for prize <- @prizes do %>
        <li>
          <%= prize.place %>
          <%= prize.prize.name %>
        </li>
      <% end %>
    </ol>
    """
  end
end
