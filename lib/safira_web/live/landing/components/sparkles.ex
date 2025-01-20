defmodule SafiraWeb.Landing.Components.Sparkles do
  @moduledoc false
  use SafiraWeb, :component

  def sparkles(assigns) do
    ~H"""
    <div class="absolute inset-0 overflow-x-clip select-none -z-10 h-full overflow-y-hidden pointer-events-none">
      <div class="absolute -top-[300px] -left-[900px] w-[2000px] hidden md:block animate-fade-in-slow">
        <.shape id="desktop-sparkle-1" />
      </div>
      <div class="absolute -top-[400px] -right-[200px] w-[1000px] hidden md:block animate-fade-in">
        <.shape id="desktop-sparkle-2" />
      </div>
      <div class="absolute right w-[700px] block md:hidden animate-fade-in">
        <.shape id="mobile-sparkle" />
      </div>
    </div>
    """
  end

  defp shape(assigns) do
    ~H"""
    <svg
      id={"#{@id}-svg"}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 375.62 375.64"
      class="blur-[40px]"
    >
      <defs>
        <radialGradient id={"#{@id}-gradient"}>
          <stop offset="10%" stop-color="#330bff" />
          <stop offset="93%" stop-color="#04030f" />
        </radialGradient>
        <style>
          .cls-1{fill:url(<%= "'##{@id}-gradient'" %>);}
        </style>
      </defs>
      <g>
        <g>
          <path
            style={"fill: url('##{@id}-gradient')"}
            d="M375.62,186.16c-147.78,23.59-165.87,41.69-189.43,189.48C165.84,227.48,148.16,209.8,0,189.47,147.78,165.89,165.88,147.79,189.43,0,209.79,148.16,227.47,165.84,375.62,186.16Z"
          />
        </g>
      </g>
    </svg>
    """
  end
end
