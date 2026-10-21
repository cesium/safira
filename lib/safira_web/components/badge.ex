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
  attr :desc_size, :atom, default: :small, values: [:small, :big]
  attr :class, :string, default: nil

  def badge(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex flex-col items-center",
        @disabled && "opacity-50",
        @hover_zoom && "group",
        @class
      ]}
    >
      <img
        :if={@badge.image}
        src={Uploaders.Badge.url({@badge.image, @badge}, :original, signed: true)}
        alt={@badge.name}
        class={[
          "p-2 #{@width} aspect-square drop-shadow-[0_0_25px_rgba(255,255,255,0.15)]",
          @hover_zoom &&
            "group-hover:scale-105 transition-transform duration-300 ease-in-out select-none"
        ]}
      />
      <img
        :if={!@badge.image}
        class={[
          "p-2 #{@width} aspect-square drop-shadow-[0_0_25px_rgba(255,255,255,0.15)]",
          @hover_zoom &&
            "group-hover:scale-105 transition-transform duration-300 ease-in-out select-none"
        ]}
        src="/images/badges/404-fallback.svg"
      />
      <span class={["w-full wrap-break-word font-semibold text-center", get_name_class(@desc_size)]}>
        {@badge.name}
      </span>
      <span
        :if={@show_tokens}
        class={["font-semibold flex place-items-center gap-2", get_tokens_class(@desc_size)]}
      >
        <.icon name="fa-sack-dollar-solid" class={get_icon_class(@desc_size)} />
        {@badge.tokens}
      </span>
    </div>
    """
  end

  defp get_name_class(:small), do: "text-sm"
  defp get_name_class(:big), do: "text-lg"

  defp get_tokens_class(:small), do: "text-sm"
  defp get_tokens_class(:big), do: "text-base"

  defp get_icon_class(:small), do: "w-3.5"
  defp get_icon_class(:big), do: "w-4"
end
