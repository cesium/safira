defmodule SafiraWeb.App.SlotsLive.Components.Machine do
  @moduledoc """
  Slots machine component.
  """
  use SafiraWeb, :component

  alias Safira.Minigames
  alias Safira.Uploaders.SlotsReelIcon

  def machine(assigns) do
    reels = Minigames.list_slots_reel_icons()
    reels_by_position = organize_reels_by_position(reels)

    assigns =
      assigns
      |> assign(:reels_by_position, reels_by_position)
      |> assign(:reel_height, calculate_height(reels_by_position))

    ~H"""
    <div id="slots-machine" phx-hook="ReelAnimation" class="w-full max-w-xl">
      <div class="flex flex-col justify-center border border-light/10 shadow-[0_0_30px_2px] shadow-accent/0 w-full rounded-xl">
        <div class="inline-flex gap-2 py-3 items-center justify-center rounded-t-xl border-b border-light/10">
          <h3 class="uppercase tracking-wider font-semibold text-accent">safira slots</h3>
        </div>

        <div class="slots-container flex gap-2 sm:gap-5 py-4 sm:py-8 px-1 sm:px-2 items-center justify-center bg-light/2">
          <%= for reel_num <- 0..2 do %>
            <div class="border border-light/10 px-2 py-2 sm:px-4 sm:py-4 rounded-xl">
              <div
                id={"slots-reel-#{reel_num}"}
                class="reel-slot"
                data-reel={reel_num}
                style={"width: 79px; height: 237px; background-size: 79px #{@reel_height}px; background-position-y: #{build_background_positions(@reels_by_position[reel_num])}; background-image: #{build_reel_background(@reels_by_position[reel_num])};"}
              />
            </div>
          <% end %>
        </div>

        <div class="inline-flex gap-2 py-3 items-center justify-center rounded-b-xl border-t border-light/10">
          <span class="h-px max-w-12 w-full bg-accent/80" />
          <p class="uppercase text-light/50 text-xs">{gettext("payline")}</p>
          <span class="h-px max-w-12 w-full bg-accent/80" />
        </div>
      </div>
    </div>
    """
  end

  defp calculate_height(reels_by_position) do
    # Get length of first reel (they should all be same length)
    {_reel_num, reel_images} = Enum.at(reels_by_position, 0)
    length(reel_images) * 79
  end

  defp organize_reels_by_position(reels) do
    reels
    |> Enum.reduce(%{0 => [], 1 => [], 2 => []}, fn reel, acc ->
      acc
      |> Map.update!(0, &[{reel, reel.reel_0_index} | &1])
      |> Map.update!(1, &[{reel, reel.reel_1_index} | &1])
      |> Map.update!(2, &[{reel, reel.reel_2_index} | &1])
    end)
    |> Map.new(fn {k, v} ->
      sorted =
        v
        |> Enum.filter(fn {_, index} -> index != -1 end)
        |> Enum.sort_by(&elem(&1, 1))

      # Rotate first 3 items to end
      {first_three, rest} = Enum.split(sorted, 3)
      {k, rest ++ first_three}
    end)
  end

  defp build_reel_background(reel_images) do
    urls =
      reel_images
      |> Enum.map_join(", ", fn {reel, _} ->
        url = SlotsReelIcon.url({reel.image, reel}, :original, signed: true)
        "url('#{url}')"
      end)

    urls
  end

  defp build_background_positions(reel_images) do
    reel_images
    |> Enum.with_index()
    |> Enum.map_join(", ", fn {_reel, index} ->
      position = index * 79
      "#{position}px"
    end)
  end
end
