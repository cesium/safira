defmodule SafiraWeb.Components.Banner do
  @moduledoc false
  use SafiraWeb, :component
  attr :text, :string, default: ""
  attr :end_time, :any, default: nil

  def banner(assigns) do
    ~H"""
    <div
      id="banner"
      phx-hook="Banner"
      class="relative w-full bg-gradient-to-b from-accent to-transparent from-85% text-center pt-2 pb-3 text-primary/70 font-bold z-10 transition-transform transform"
      data-end={@end_time}
    >
      <p><%= @text %></p>
      <div id="timer-countdown">
        --:--:--
      </div>
    </div>
    """
  end
end
