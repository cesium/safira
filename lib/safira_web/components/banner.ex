defmodule SafiraWeb.Components.Banner do
  use SafiraWeb, :component

  attr :title, :string, default: ""
  attr :message, :string, default: ""
  attr :duration, :integer, default: 500
  attr :type, :string, default: "info"
  attr :company_name, :string, default: ""

  def banner(assigns) do
    IO.inspect(assigns, label: "Banner do Jurukage")
    ~H"""
    <div id="spotlight-banner" phx-hook="SpotlightBanner" class="fixed top-[-100px] left-0 w-full bg-yellow-400 text-center p-4 text-black font-bold shadow-lg z-50">
      <%= gettext("%{company_name} is on spotlight!", company_name:  @company_name) %>
    </div>

    """
  end
end
