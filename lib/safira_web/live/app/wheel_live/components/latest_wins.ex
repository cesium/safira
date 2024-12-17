defmodule SafiraWeb.App.WheelLive.Components.LatestWins do
  @moduledoc """
  Lucky wheel latest wins component.
  """
  use SafiraWeb, :component

  attr :entries, :list, default: []

  def latest_wins(assigns) do
    ~H"""
    <table class="m-auto">
      <tr>
        <th class="px-4">Attendee</th>
        <th class="px-4">Prize</th>
        <th class="px-4">When</th>
      </tr>
      <%= for entry <- @entries do %>
        <tr>
          <td class="px-4"><%= entry.attendee.user.name %></td>
          <td class="px-4"><%= entry_name(entry) %></td>
          <td class="px-4"><%= Timex.from_now(entry.inserted_at) %></td>
        </tr>
      <% end %>
    </table>
    """
  end

  defp entry_name(entry) do
    if is_nil(entry.drop) do
      # TODO: Remove
      "Nothing"
    else
      if is_nil(entry.drop.badge) do
        entry.drop.prize.name
      else
        entry.drop.badge.name
      end
    end
  end
end
