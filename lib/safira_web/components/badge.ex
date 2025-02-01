defmodule SafiraWeb.Components.Badge do
  @moduledoc false
  use SafiraWeb, :component

  alias Safira.Contest

  attr :id, :string, required: true
  attr :badge, Contest.Badge, required: true
  attr :disabled, :boolean, default: false
  attr :hover_zoom, :boolean, default: false

  def badge(assigns) do
    ~H"""
      <div id={@id} class={["flex flex-col items-center", @disabled && "opacity-50", @hover_zoom && "group"]}>
        <img
          :if={@badge.image}
          src={Uploaders.Badge.url({@badge.image, @badge}, :original, signed: true)}
          alt={@badge.name}
          class={["p-2 w-64 h-64", @hover_zoom && "group-hover:scale-105 transition-transform duration-300 ease-in-out"]}
        />
        <img :if={!@badge.image} class={["p-2 w-64 h-64", @hover_zoom && "group-hover:scale-105 transition-transform duration-300 ease-in-out"]} src="/images/badges/404-fallback.svg" />
        <span class="text-sm font-semibold">
          <%= @badge.name %>
        </span>
        <span class="text-sm font-semibold">
          💰 <%= @badge.tokens %>
        </span>
      </div>
    """
  end
end
