defmodule SafiraWeb.Components.Banner do
  use SafiraWeb, :component

  attr :text, :string, default: ""
  attr :duration, :integer, default: 5000

  def banner(assigns) do
    ~H"""
    <div
      id="banner"
      phx-hook="Banner"
      class="relative w-full bg-white text-center p-4 text-black font-bold shadow-lg z-10 transition-transform transform"
      style="top: 0;"
      data-duration={@duration}
    >
      <p><%= @text %></p>
      <div id="timer-countdown" phx-hook="Timer" data-finish-time={DateTime.to_unix(@duration)}>
        00:00:00
      </div>
    </div>
    """
  end
end
