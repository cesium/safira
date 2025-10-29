defmodule SafiraWeb.App.WheelLive.Components.LatestWins do
  @moduledoc """
  Lucky wheel latest wins component.
  """
  use SafiraWeb, :component

  attr :entries, :list, default: []

  def latest_wins(assigns) do
    ~H"""
    <table class="w-full">
      <tr class="border-b-2 text-md sm:text-lg">
        <th class="pr-2 text-left">{gettext("Attendee")}</th>
        <th class="px-4 text-center">{gettext("Prize")}</th>
        <th class="pl-2 text-right">{gettext("When")}</th>
      </tr>
      <%= for entry <- @entries do %>
        <tr class="text-sm sm:text-md">
          <td class="pr-2 py-2 font-bold text-left">{entry.attendee.user.name}</td>
          <td class="px-4 py-2 text-center">{entry_name(entry)}</td>
          <td class="pl-2 py-2 text-accent font-bold text-right">
            {Timex.from_now(entry.inserted_at)}
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
