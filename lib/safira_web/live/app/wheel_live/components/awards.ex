defmodule SafiraWeb.App.WheelLive.Components.Awards do
  @moduledoc """
  Lucky wheel awards component.
  """
  use SafiraWeb, :component

  attr :entries, :list, default: []

  def awards(assigns) do
    ~H"""
    <ul class="w-full divide-y divide-light/5 border-t border-light/10">
      <%= for entry <- @entries do %>
        <li class="flex flex-row w-full lg:gap-4 py-4 lg:px-4 items-center justify-between">
          <div class="min-w-0">
            <p class="text-sm lg:text-base font-semibold truncate">{entry_name(entry)}</p>
            <p class="text-xs lg:text-sm text-light/50">
              {gettext("Stock")}:
              <%= case entry_stock(entry) do %>
                <% :infinity -> %>
                  <.icon name="fa-infinity-solid" class="size-4" />
                <% stock -> %>
                  {stock}
              <% end %>
              <span class="px-2">-</span>
              {gettext("Max/attendee")}: {entry.max_per_attendee}
            </p>
          </div>

          <div class="text-right">
            <p class="text-light/50 text-xs">Probability:</p>
            <p class="text-sm lg:text-base text-accent font-bold text-right shrink-0">
              {entry_probability(entry)}
            </p>
          </div>
        </li>
      <% end %>
      <li class="hidden only:flex w-full h-full flex-col items-center justify-center py-16 opacity-80 text-light/70">
        {gettext("No awards have been added yet.")}
      </li>
    </ul>
    """
  end

  defp entry_probability(drop) do
    "#{Float.round(drop.probability * 100, 2)}%"
  end

  defp entry_stock(drop) do
    if is_nil(drop.prize) do
      :infinity
    else
      drop.prize.stock
    end
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
