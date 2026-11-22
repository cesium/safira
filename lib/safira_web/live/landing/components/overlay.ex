defmodule SafiraWeb.Landing.Components.Overlay do
  @moduledoc """
  Black overlay over the metaballs background, optionally fading from/to transparent
  """
  use SafiraWeb, :component

  attr :fade, :atom,
    values: [nil, :in, :out],
    default: nil,
    doc: ":in goes from transparent at the top to black, :out from black to transparent"

  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def overlay(assigns) do
    ~H"""
    <div
      class={[
        "flow-root",
        case @fade do
          nil ->
            "bg-black"

          :in ->
            "bg-linear-to-b from-transparent via-black/27 via-36% to-black to-98%"

          :out ->
            "bg-linear-to-t from-transparent via-black/70 via-45% to-black to-90%"
        end,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
