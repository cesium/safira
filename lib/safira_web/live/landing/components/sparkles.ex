defmodule SafiraWeb.Landing.Components.Sparkles do
  @moduledoc false
  use SafiraWeb, :component

  def sparkles(assigns) do
    ~H"""
      <div class="relative overflow-x-clip select-none">
        <div class="absolute -top-[300px] -left-[900px] w-[2000px] hidden md:block">
            <img src="/images/sparkle.svg">
        </div>
        <div class="absolute -top-[400px] -right-[200px] w-[1000px] hidden md:block">
            <img src="/images/sparkle.svg">
        </div>
        <div class="absolute right w-[700px] block md:hidden">
            <img src="/images/sparkle.svg">
        </div>
      </div>
    """
  end
end
