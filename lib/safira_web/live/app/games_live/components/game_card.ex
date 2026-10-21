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
      class="flex flex-col h-full group gap-6 rounded-2xl border border-white/10 bg-black/20 p-8 backdrop-blur-md transition-all duration-500 hover:border-white/20 hover:bg-black/30 hover:shadow-2xl hover:shadow-primary/10"
    >
      <img src={~p"/images/icons/#{@icon}"} class="size-16 sm:size-24 invert" />
      <div class="gap-2">
        <p class="text-2xl font-bold">{@name}</p>
        <p class="text-white/60">{@desc}</p>
      </div>
      <div class="inline-flex items-center gap-2 group-hover:gap-3 transition-all duration-300">
        <p>Play Now</p>
        <.icon name="hero-arrow-right" class="size-4" />
      </div>
    </.link>
    """
  end
end
