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
    <div class="flex justify-center pb-4">
      <button
        disabled={not @left_enabled}
        class={[
          enabled_class(@left_enabled),
          "text-light/50 hover:text-light hover:scale-90 px-2 transition-all duration-300"
        ]}
        phx-click={@on_left}
      >
        <.icon name="hero-chevron-left" class="w-8 h-8" />
      </button>

      <h2 class="min-w-30 text-center uppercase leading-tight">
        <span class="block text-xs tracking-wide text-light/50">{gettext("Day")}</span>
        <span class="block text-2xl sm:text-2xl text-accent font-semibold">{@day}</span>
      </h2>

      <button
        disabled={not @right_enabled}
        class={[
          enabled_class(@right_enabled),
          "text-light/50 hover:text-light hover:scale-90 px-2 transition-all duration-300"
        ]}
        phx-click={@on_right}
      >
        <.icon name="hero-chevron-right" class="w-8 h-8" />
      </button>
    </div>
    """
  end

  defp enabled_class(enabled) do
    if enabled do
      "cursor-pointer"
    else
      "opacity-0"
    end
  end
end
