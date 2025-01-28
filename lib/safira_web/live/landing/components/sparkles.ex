defmodule SafiraWeb.Landing.Components.Sparkles do
  @moduledoc false
  use SafiraWeb, :component

  def sparkles(assigns) do
    ~H"""
    <div class="absolute inset-0 overflow-x-clip select-none -z-10 h-full overflow-y-hidden pointer-events-none blur-[40px]">
      <div class="absolute -top-[300px] -left-[900px] w-[2000px] hidden md:block animate-fade-in-slow">
        <img src="/images/starts.svg" id="desktop-sparkle-1" />
      </div>
      <div class="absolute -top-[400px] -right-[200px] w-[1000px] hidden md:block animate-fade-in">
        <img src="/images/starts.svg" id="desktop-sparkle-2" />
      </div>
      <div class="absolute right w-[700px] block md:hidden animate-fade-in">
        <img src="/images/starts.svg" id="desktop-sparkle-3" />
      </div>
    </div>
    """
  end
end
