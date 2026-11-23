defmodule SafiraWeb.Components.Metaballs do
  @moduledoc """
  Animated metaballs background, drawn by the Metaballs hook.
  """

  use SafiraWeb, :component

  attr :id, :string, default: "metaballs"

  def metaballs(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Metaballs"
      phx-update="ignore"
      aria-hidden="true"
      class="pointer-events-none fixed inset-0 -z-10 h-screen bg-[#0e00b6] bg-linear-to-t from-[#0e00b6] to-[#0a0855]"
    >
      <canvas class="absolute inset-0 h-full w-full"></canvas>
    </div>
    """
  end
end
