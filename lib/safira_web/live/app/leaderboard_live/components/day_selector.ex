defmodule SafiraWeb.App.LeaderboardLive.Components.DaySelector do
  @moduledoc """
  Leaderboard component
  """

  use SafiraWeb, :component

  attr :day, :string, required: true
  attr :on_left, :any, required: true
  attr :on_right, :any, required: true
  attr :left_enabled, :boolean, required: true
  attr :right_enabled, :boolean, required: true

  def day_selector(assigns) do
    ~H"""
    <div class="flex justify-center">
      <button disabled={not @left_enabled} class={enabled_class(@left_enabled)} phx-click={@on_left}>
        <.icon name="hero-chevron-left" class="w-8 h-8" />
      </button>
      <h2 class="mx-8 text-4xl text-accent font-terminal uppercase"><%= @day %></h2>
      <button
        disabled={not @right_enabled}
        class={enabled_class(@right_enabled)}
        phx-click={@on_right}
      >
        <.icon name="hero-chevron-right" class="w-8 h-8" />
      </button>
    </div>
    """
  end

  defp enabled_class(enabled) do
    if enabled do
      ""
    else
      "opacity-0"
    end
  end
end
