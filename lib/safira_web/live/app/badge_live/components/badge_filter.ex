defmodule SafiraWeb.App.BadgeLive.Components.BadgeFilter do
  @moduledoc false
  use SafiraWeb, :component

  attr :selection, :atom, required: true

  def badge_filter(assigns) do
    ~H"""
    <div class="relative grid grid-cols-2 rounded-full bg-light/5 p-1">
      <span class={get_indicator_classes(@selection)}></span>

      <button
        type="button"
        phx-click="set-selection"
        phx-value-selection="all"
        class={get_tab_classes(assigns.selection == :all)}
      >
        {gettext("All")}
      </button>

      <button
        type="button"
        phx-click="set-selection"
        phx-value-selection="redeemed"
        class={get_tab_classes(assigns.selection == :redeemed)}
      >
        {gettext("Mine")}
      </button>
    </div>
    """
  end

  defp get_indicator_classes(:all) do
    "absolute left-1 top-1 bottom-1 w-1/2 rounded-full bg-accent transition-transform duration-300 ease-out"
  end

  defp get_indicator_classes(:redeemed) do
    "absolute -left-1 top-1 bottom-1 w-1/2 rounded-full bg-accent translate-x-full transition-transform duration-300 ease-out"
  end

  defp get_tab_classes(true) do
    "relative z-10 rounded-full px-6 py-2 text-sm font-semibold uppercase text-primary transition-colors duration-300"
  end

  defp get_tab_classes(false) do
    "relative z-10 rounded-full px-6 py-2 text-sm font-semibold uppercase text-white/50 transition-colors duration-300 hover:text-white/70 cursor-pointer"
  end
end
