defmodule SafiraWeb.Landing.HomeLive.Components.Pitch do
  @moduledoc false
  use SafiraWeb, :component

  # import SafiraWeb.Components.Button

  def pitch(assigns) do
    ~H"""
    <div class="relative mt-20 grid md:grid md:grid-cols-2">
      <div class="mt-20 text-white sm:mt-0">
        <h3 class="font-terminal uppercase select-none text-4xl">
          What you can expect:
        </h3>
        <ul class="mt-8 list-disc pl-4 font-iregular">
          <li>Talks</li>
          <li>Workshops</li>
          <li>Challenges</li>
          <li>Contests</li>
        </ul>
      </div>
      <div class="xl:9/12 font-terminal uppercase w-full select-none tracking-wide text-white md:pt-0 pt-16">
        <h2 class="text-4xl">
          <%= gettext(
            "We gather speakers, attract partners and give our imagination wings, all for this to be your favorite week."
          ) %>
        </h2>
      </div>
    </div>
    """
  end
end
