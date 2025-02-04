defmodule SafiraWeb.App.WheelLive.Components.Awards do
  @moduledoc """
  Lucky wheel awards component.
  """
  use SafiraWeb, :component

  attr :entries, :list, default: []

  def awards(assigns) do
    ~H"""
    <table class="w-full">
      <tr class="border-b-2 text-md sm:text-lg">
        <th class="pr-2 text-left">Name</th>
        <th class="px-4 sm:block hidden text-center">Stock</th>
        <th class="px-4 text-center">Max. / Attendee</th>
        <th class="pl-2 text-right">Probability</th>
      </tr>
      <%= for entry <- @entries do %>
        <tr class="text-sm sm:text-md">
          <td class="pr-2 py-2 font-bold text-left"><%= entry_name(entry) %></td>
          <td class="px-4 sm:block hidden py-2 font-bold text-center"><%= entry_stock(entry) %></td>
          <td class="px-4 py-2 text-center"><%= entry.max_per_attendee %></td>
          <td class="pl-2 py-2 text-accent font-bold text-right">
            <%= format_probability(entry.probability) %>
          </td>
        </tr>
      <% end %>
    </table>
    """
  end

  defp entry_stock(drop) do
    if is_nil(drop.prize) do
      "∞"
    else
      drop.prize.stock
    end
  end

  defp format_probability(probability) do
    "#{probability * 100} %"
  end

  defp entry_name(drop) do
    cond do
      not is_nil(drop.prize) ->
        drop.prize.name

      not is_nil(drop.badge) ->
        drop.badge.name

      drop.entries > 0 ->
        "#{drop.entries} Entries"

      drop.tokens > 0 ->
        "#{drop.tokens} Tokens"
    end
  end
end
