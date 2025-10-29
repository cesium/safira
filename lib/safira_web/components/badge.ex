defmodule SafiraWeb.Components.Badge do
  @moduledoc false
  use SafiraWeb, :component

  alias Safira.Contest

  attr :id, :string, required: true
  attr :badge, Contest.Badge, required: true
  attr :disabled, :boolean, default: false
  attr :hover_zoom, :boolean, default: false
  attr :width, :string, default: "w-64"
  attr :show_tokens, :boolean, default: false

  def badge(assigns) do
    ~H"""
    <div
      id={@id}
      class={["flex flex-col items-center", @disabled && "opacity-50", @hover_zoom && "group"]}
    >
      <img
        :if={@badge.image}
        src={Uploaders.Badge.url({@badge.image, @badge}, :original, signed: true)}
        alt={@badge.name}
        class={[
          "p-2 #{@width} aspect-square",
          @hover_zoom &&
            "group-hover:scale-105 transition-transform duration-300 ease-in-out select-none"
        ]}
      />
      <img
        :if={!@badge.image}
        class={[
          "p-2 #{@width} aspect-square",
          @hover_zoom &&
            "group-hover:scale-105 transition-transform duration-300 ease-in-out select-none"
        ]}
        src="/images/badges/404-fallback.svg"
      />
      <span class="text-sm font-semibold text-center">
        {@badge.name}
      </span>
      <span :if={@show_tokens} class="text-sm font-semibold">
        💰 {@badge.tokens}
      </span>
    </div>
    """
  end
end
