defmodule SafiraWeb.App.LeaderboardLive.Components.Prizes do
  @moduledoc """
  Prizes component
  """

  use SafiraWeb, :component

  attr :prizes, :list, required: true

  def prizes(assigns) do
    ~H"""
    <div class="mt-8 ">
      <ol class="mt-8">
        <%= for prize <- @prizes do %>
          <li class="py-1">
            <span class={"mr-2 font-bold #{medal_color(prize.place)}"}>
              <%= prize.place %><sup><%= get_exponent(prize.place) %></sup> <%= gettext("Place") %>:
            </span>
            <%= prize.prize.name %>
          </li>
        <% end %>
      </ol>
    </div>
    """
  end

  defp get_exponent(place) do
    case place do
      1 -> "st"
      2 -> "nd"
      3 -> "rd"
    end
  end

  defp medal_color(place) do
    case place do
      1 -> "text-amber-400"
      2 -> "text-neutral-400"
      3 -> "text-orange-400"
    end
  end
end
