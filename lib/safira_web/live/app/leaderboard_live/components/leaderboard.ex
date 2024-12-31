defmodule SafiraWeb.App.LeaderboardLive.Components.Leaderboard do
  @moduledoc """
  Leaderboard component
  """

  use SafiraWeb, :component

  attr :entries, :list, required: true
  attr :user_position, :any, required: true

  def leaderboard(assigns) do
    ~H"""
    <table class="w-full">
      <tr>
        <th class="font-bold text-lg text-left pb-2">Position</th>
        <th class="font-bold text-lg text-center pb-2">Attendee</th>
        <th class="font-bold text-lg text-center pb-2">Badge Count</th>
        <th class="font-bold text-lg text-right pb-2">Token Count</th>
      </tr>
      <%= for entry <- @entries do %>
        <tr>
          <td class={color_class(entry.position, @user_position.position) <> " text-left py-1"}>
            <%= entry.position %>
          </td>
          <td class={color_class(entry.position, @user_position.position) <> " text-center py-1"}>
            <%= entry.name %>
          </td>
          <td class={color_class(entry.position, @user_position.position) <> " text-center py-1"}>
            <%= entry.badges %>
          </td>
          <td class={color_class(entry.position, @user_position.position) <> " text-right py-1"}>
            <%= entry.tokens %>
          </td>
        </tr>
      <% end %>
      <%= if not Enum.member?(Enum.map(@entries, fn e -> e.position end), @user_position.position) do %>
        <tr>
          <td class="text-accent font-bold text-left pt-4 pb-1"><%= @user_position.position %></td>
          <td class="text-accent font-bold text-center pt-4 pb-1"><%= @user_position.name %></td>
          <td class="text-accent font-bold text-center pt-4 pb-1"><%= @user_position.badges %></td>
          <td class="text-accent font-bold text-right pt-4 pb-1"><%= @user_position.tokens %></td>
        </tr>
      <% end %>
    </table>
    """
  end

  defp color_class(pos, user_pos) do
    case pos do
      1 ->
        "text-amber-400 font-bold"

      2 ->
        "text-neutral-400 font-bold"

      3 ->
        "text-orange-400 font-bold"

      _ ->
        if pos == user_pos do
          "text-accent font-bold"
        else
          ""
        end
    end
  end
end
