defmodule SafiraWeb.App.GamesLive.Components.GameCard do
  @moduledoc """
    Minigame Card.
  """
  use SafiraWeb, :component

  attr :name, :string, required: true
  attr :path, :string, required: true
  attr :desc, :string, required: true
  attr :icon, :string, required: true

  def game_card(assigns) do
    ~H"""
    <.link
      navigate={"/app/games/#{@path}"}
      class="flex flex-col h-full group gap-6 border-white/10 border-2 rounded-xl bg-black/20 p-8 backdrop-blur-md hover:-translate-y-1 transition-all duration-300 hover:border-accent/80 hover:shadow-[0_0_20px_2px] hover:shadow-accent/30"
    >
      <img src={~p"/images/icons/#{@icon}"} class="size-16 sm:size-24 invert" />
      <div class="space-y-2 flex-col flex-1">
        <p class="text-2xl font-bold">{@name}</p>
        <p class="text-white/60">{@desc}</p>
      </div>
      <div class="inline-flex items-center gap-2 group-hover:gap-3 transition-all duration-300">
        <p>Play Now</p>
        <.icon name="hero-chevron-right" class="size-4" />
      </div>
    </.link>
    """
  end
end
