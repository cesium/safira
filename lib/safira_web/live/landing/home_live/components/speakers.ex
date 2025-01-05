defmodule SafiraWeb.Landing.HomeLive.Components.Speakers do
  @moduledoc false
  use SafiraWeb, :component

  import SafiraWeb.Components.Button
  import SafiraWeb.Landing.Components.Speaker

  attr :speakers, :list, required: true

  def speakers(assigns) do
    ~H"""
    <div class="spacing flex flex-col justify-normal lg:justify-between gap-8 lg:gap-64 pt-20 lg:flex-row">
      <div class="mb-10 lg:w-1/2">
        <h2 class="font-terminal uppercase mb-8 select-none text-4xl text-white xs:text-5xl lg:text-6xl">
          Here's a selection of this year's speakers
        </h2>
        <div class="xs:w-70 w-60 sm:w-80">
          <.link navigate={~p"/"}>
            <.action_button title="MEET THE SPEAKERS" title_class="!text-lg !font-iregular font-bold" />
          </.link>
        </div>
      </div>
      <ul
        id="speakers"
        class="grid grid-cols-2 justify-items-center gap-y-8 gap-x-2 lg:gap-x-8"
        phx-update="stream"
      >
        <li :for={{id, speaker} <- @speakers} id={id}>
          <.speaker speaker={speaker} />
        </li>
      </ul>
    </div>
    """
  end
end
