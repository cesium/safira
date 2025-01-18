defmodule SafiraWeb.Landing.Components.JoinUs do
  @moduledoc false
  use SafiraWeb, :component

  def join_us(assigns) do
    ~H"""
    <.link
      navigate={~p"/users/register"}
      class="before:ease font-terminal uppercase relative flex h-10 w-28 flex-wrap content-center justify-center overflow-hidden rounded-full border-2 border-white bg-accent text-white transition-transform before:absolute before:left-0 before:-ml-2 before:h-48 before:w-48 before:origin-top-right before:-translate-x-full before:translate-y-12 before:-rotate-90 before:bg-accent before:transition-all before:duration-300 hover:scale-105 hover:text-white hover:before:-rotate-180 lg:bg-transparent"
    >
      <span class="relative z-10">Join Us</span>
    </.link>
    """
  end
end
