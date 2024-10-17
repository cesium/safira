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
        <div class="grid grid-cols-2 place-items-center gap-4 p-6 lg:gap-10">
          <%= for sponsor <- @sponsors do %>
            <.link href={sponsor.url} target="_blank">
              <%= if sponsor.logo do %>
                <img
                  class="w-full p-4"
                  src={Uploaders.Company.url({sponsor.logo, sponsor}, :original)}
                />
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
