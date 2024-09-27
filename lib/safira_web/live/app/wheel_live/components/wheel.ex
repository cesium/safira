defmodule SafiraWeb.App.WheelLive.Components.Wheel do
  use SafiraWeb, :component

  attr :slices, :integer, default: 10

  def wheel(assigns) do
    ~H"""
    <div class="m-auto mt-8 h-72 w-72 xs:h-80 xs:w-80 sm:h-96 sm:w-96">
      <div id="wheel-container" phx-hook="Wheel" class="relative h-full w-full">
        <div class="ring-white ring-8 h-full w-full rounded-full">
          <div
            id="wheel"
            class="h-full w-full rounded-full drop-shadow-[0_0px_10px_rgba(0,0,0,0.7)]"
            style="background: conic-gradient(#ff800d,#fc993f,#ff800d,#fc993f,#ff800d);"
          >
            <%= for i <- 0..@slices do %>
              <div
                class="absolute top-[50%] left-[50%] h-[1px] w-[50%] rotate-[10deg] bg-white"
                style={"transform: rotate(" <> to_string(i * (360/@slices)) <> "deg); transform-origin: 0% 50%;"}
              >
              </div>
            <% end %>
          </div>
        </div>
        <div
          id="arrow"
          class="absolute top-0 flex h-full w-full select-none flex-wrap content-center justify-center"
        >
          <img class="mb-5 h-12 w-12" src={~p"/images/wheel-arrow.svg"} />
        </div>
      </div>
    </div>
    """
  end
end
