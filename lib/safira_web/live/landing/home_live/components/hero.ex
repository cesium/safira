defmodule SafiraWeb.Landing.HomeLive.Components.Hero do
  @moduledoc false
  use SafiraWeb, :component

  import SafiraWeb.Landing.Components.{JoinUs, Socials}

  def hero(assigns) do
    ~H"""
    <div class="mt-2">
      <div class="select-none">
        <div class="py-14 sm:py-28">
          <.title />
        </div>
        <div class="relative mt-24 text-white">
          <div class="flex items-center justify-between pb-4">
            <div class="flex flex-col gap-4">
              <h5 class="font-imedium"><%= gettext("Follow us on") %></h5>
              <.socials />
              <div class="lg:hidden">
                <.join_us />
              </div>
            </div>
            <div class="absolute right-0 hidden lg:block">
              <.organization />
            </div>
          </div>
          <div class="mt-10 lg:hidden">
            <.organization />
          </div>
        </div>
      </div>
    </div>
    """
  end

  def title(assigns) do
    ~H"""
    <div class="relative z-20 font-bold">
      <h5 class="font-terminal uppercase m-1 text-2xl text-accent">
        11-14 February 2025
      </h5>
      <h1 class="font-terminal uppercase relative z-20 w-11/12 text-white text-5xl xs:text-5xl sm:text-6xl md:w-full md:text-7xl lg:text-8xl 2xl:w-5/6 2xl:text-8xl 2xl:leading-[5rem]">
        <span class="relative z-20">
          The software engineering week is back, let's just
          <span class="underline decoration-8 underline-offset-8">
            SEI
          </span>
          that.
        </span>
      </h1>
    </div>
    """
  end

  def organization(assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <h5 class="font-imedium text-white"><%= gettext("Organization") %></h5>
      <a href="https://cesium.pt">
        <img src="/images/cesium-logo.svg" width="120" height="41" alt="CeSIUM" class="select-none" />
      </a>
    </div>
    """
  end
end
