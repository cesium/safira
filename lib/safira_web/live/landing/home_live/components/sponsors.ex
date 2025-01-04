defmodule SafiraWeb.Landing.HomeLive.Components.Sponsors do
  @moduledoc false
  use SafiraWeb, :component

  alias Safira.Uploaders

  def sponsors(assigns) do
    ~H"""
    <div class="flex items-center justify-center flex-col">
      <h2 class="font-terminal uppercase flex justify-center py-10 text-center text-4xl xs:text-5xl sm:text-6xl md:text-7xl">
        <%= gettext("Our amazing sponsors") %>
      </h2>
      <%= for tier <- @tiers do %>
        <.sponsor_segment tier={tier.name} sponsors={tier.companies} />
      <% end %>
    </div>
    """
  end

  def sponsor_segment(assigns) do
    ~H"""
    <div class="flex flex-col justify-center pt-10 sm:pt-20 lg:flex-row">
      <div class="grid w-full grid-cols-1 place-items-center py-[5%] lg:py-0 lg:px-[10%]">
        <p class="font-terminal uppercase pb-10 text-2xl text-accent lg:text-3xl">
          <%= @tier %>
        </p>
        <div class="flex justify-center items-center flex-wrap gap-4 sm:p-6 lg:gap-10">
          <%= for sponsor <- @sponsors |> Enum.shuffle() do %>
            <.link
              href={sponsor.url}
              target="_blank"
              class="opacity-80 hover:opacity-100 hover:scale-105 duration-500 transition-all"
            >
              <%= if sponsor.logo do %>
                <div class="w-32 sm:w-64 py-4">
                  <img
                    class="w-full max-h-32 px-1 sm:px-4"
                    src={Uploaders.Company.url({sponsor.logo, sponsor}, :original)}
                  />
                </div>
              <% else %>
                <p class="text-2xl text-center p-2">
                  <%= sponsor.name %>
                </p>
              <% end %>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
