defmodule SafiraWeb.Landing.Components.Footer do
  @moduledoc """
  Footer component.
  """
  use SafiraWeb, :component
  import SafiraWeb.Landing.Components.Socials

  def footer(assigns) do
    ~H"""
    <footer>
      <div class="flex flex-col justify-between gap-16 py-10 lg:flex-row">
        <div class="flex select-none items-start justify-center lg:justify-start">
          <img src="/images/sei-logo.svg" width={100} height={100} alt="SEI Logo" />
          <p class="pl-6 text-white font-semibold lg:flex-1">
            Semana da <br /> Engenharia <br /> Informática
          </p>
        </div>

        <div class="flex-2">
          <div class="grid select-none grid-rows-2 justify-items-center gap-8 whitespace-nowrap font-iregular text-sm text-white lg:grid-cols-2 lg:justify-items-start">
            <%= for link <- footer_links() do %>
              <.link href={link.url} class="hover:underline">
                <%= link.title %>
              </.link>
            <% end %>
          </div>
          <div class="flex justify-center lg:justify-end">
            <div class="pt-10 lg:pt-5 text-white lg:mt-0">
              <.socials />
            </div>
          </div>
        </div>
      </div>
    </footer>
    """
  end

  defp footer_links do
    [
      %{
        title: "Previous Edition",
        url: "https://2024.seium.org/"
      },
      %{
        title: "Report a Problem",
        url: "https://cesium.link/f/safira-bugs"
      },
      %{
        title: "Survival Guide",
        url: "/docs/survival.pdf"
      },
      %{
        title: "General Regulation",
        url: "/docs/regulation.pdf"
      }
    ]
  end
end
