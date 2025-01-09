defmodule SafiraWeb.Components.Banner do
  use SafiraWeb, :component

  attr :title, :string, default: ""
  attr :duration, :integer, default: 5000
  attr :type, :string, default: "info"
  attr :company_name, :string, default: ""

  def banner(assigns) do
    ~H"""
    <div id="spotlight-banner"
         phx-hook="SpotlightBanner"
         class="relative w-full bg-white text-center p-4 text-black font-bold shadow-lg z-10 transition-transform transform"
         style="top: 0;"
         data-duration={@duration}>
      <%= gettext("%{company_name} is on spotlight!", company_name: @company_name) %>
      <div
        id="timer-countdown"
        phx-hook="Timer"
        data-finish-time={DateTime.to_unix(@duration)}>
        00:00:00
      </div>
    </div>
    """
  end
end
