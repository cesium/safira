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
    <div id="slots-machine" phx-hook="ReelAnimation" data-num-icons={length(reels_by_position[0])}>
      <div class="flex justify-center">
        <div class="slots-container flex gap-5 rounded-3xl py-6 px-12 ring-2 ring-white">
          <%= for reel_num <- 0..2 do %>
            <div
              id={"slots-reel-#{reel_num}"}
              class="reel-slot rounded-3xl ring-2 ring-white"
              data-reel={reel_num}
              style={"width: 79px; height: 237px; background-size: 79px #{@reel_height}px; background-position-y: #{build_background_positions(@reels_by_position[reel_num])}; background-image: #{build_reel_background(@reels_by_position[reel_num])};"}
            />
          <% end %>
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
