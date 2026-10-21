defmodule SafiraWeb.App.LeaderboardLive.Components.Prizes do
  @moduledoc """
  Prizes component
  """

  use SafiraWeb, :component

  attr :prizes, :list, required: true

  def prizes(assigns) do
    sorted_prizes = Enum.sort_by(assigns.prizes, & &1.place)
    assigns = assign(assigns, :sorted_prizes, sorted_prizes)

    ~H"""
    <div class="mt-8 flex flex-col gap-8 bg-light/2 border border-light/5 p-5 md:p-8 rounded-xl w-full h-full">
      <h2 class="uppercase flex items-center gap-2 text-light/50 text-sm">
        <.icon name="hero-trophy-solid" class="size-3.5 sm:size-4 text-accent" />
        {gettext("Prizes")}
      </h2>

      <ol class="mt-4 grid grid-cols-3 items-end gap-2 sm:gap-4">
        <%= for prize <- @sorted_prizes do %>
          <li class={podium_item_order_classes(prize.place)}>
            <.prize_col prize={prize} />
          </li>
        <% end %>
      </ol>
    </div>
    """
  end

  attr :prize, :map, required: true

  defp prize_col(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-2 sm:gap-6">
      <div class="flex flex-col items-center gap-2">
        <.icon name="hero-trophy" class={"size-4 sm:size-5.5 #{get_place_classes(@prize.place)}"} />
        <h3 class="font-bold leading-tight text-sm sm:text-base text-center wrap-break-word">
          {@prize.prize.name}
        </h3>
        <p class="uppercase font-bold text-[10px] text-light/50 tracking-wide">
          {@prize.place}<sup>{get_exponent(@prize.place)}</sup> {gettext("Place")}
        </p>
      </div>
      <div class={[
        "w-full max-w-full mx-auto border-x border-t rounded-t-lg bg-linear-to-b",
        get_podium_classes(@prize.place)
      ]}>
      </div>
    </div>
    """
  end

  defp get_exponent(place) do
    case place do
      1 -> "st"
      2 -> "nd"
      3 -> "rd"
    end
  end

  defp get_podium_classes(place) do
    case place do
      1 -> "from-amber-400/20 to-amber-400/10 border-amber-400/25 h-14 sm:h-28"
      2 -> "from-neutral-400/20 to-neutral-400/10 border-neutral-400/25 h-10 sm:h-20"
      3 -> "from-orange-400/20 to-orange-400/10 border-orange-400/25 h-8 sm:h-14.5"
    end
  end

  defp podium_item_order_classes(place) do
    case place do
      1 -> "order-2"
      2 -> "order-1"
      3 -> "order-3"
      _ -> "order-none"
    end
  end

  defp get_place_classes(place) do
    case place do
      1 -> "text-amber-400/80"
      2 -> "text-neutral-400/80"
      3 -> "text-orange-400/80"
    end
  end
end
