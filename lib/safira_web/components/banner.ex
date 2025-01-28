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
      class="relative w-full bg-white text-center p-4 text-black font-bold shadow-lg z-10 transition-transform transform"
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
