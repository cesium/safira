defmodule SafiraWeb.App.WheelLive.Components.LatestWins do
  @moduledoc """
  Lucky wheel latest wins component.
  """
  use SafiraWeb, :component

  attr :entries, :list, default: []

  def latest_wins(assigns) do
    ~H"""
    <table class="w-full">
      <tr class="border-b-2">
        <th class="px-4 text-lg text-left"><%= gettext("Attendee") %></th>
        <th class="px-4 text-lg text-center"><%= gettext("Prize") %></th>
        <th class="px-4 text-lg text-right"><%= gettext("When") %></th>
      </tr>
      <%= for entry <- @entries do %>
        <tr>
          <td class="px-4 py-2 font-bold text-left"><%= entry.attendee.user.name %></td>
          <td class="px-4 py-2 text-center"><%= entry_name(entry) %></td>
          <td class="px-4 py-2 text-accent font-bold text-right">
            <%= Timex.from_now(entry.inserted_at) %>
          </td>
        </tr>
      <% end %>
    </table>
    """
  end

  defp entry_name(entry) do
    if is_nil(entry.drop.badge) do
      entry.drop.prize.name
    else
      entry.drop.badge.name
    end
  end
end
