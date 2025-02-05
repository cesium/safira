defmodule SafiraWeb.Landing.Components.Footer do
  @moduledoc """
  Footer component.
  """
  use SafiraWeb, :component
  import SafiraWeb.Landing.Components.Socials

  alias Safira.Event

  slot :tip, required: false

  def footer(assigns) do
    ~H"""
    <footer class="xl:px-[15rem] md:px-[8rem] px-[2.5rem]">
      <div class="flex flex-col justify-between gap-16 py-10 lg:flex-row items-center">
        <div class="flex select-none items-start justify-center lg:justify-start">
          <img src="/images/sei-logo.svg" width={100} height={100} alt="SEI Logo" />
          <p class="pl-6 text-white font-semibold lg:flex-1">
            Semana da <br /> Engenharia <br /> Informática
          </p>
        </div>
        <div class="flex-2">
          <div class="grid lg:grid-flow-col lg:auto-rows-max gap-8 grid-cols-1 lg:grid-rows-2 select-none justify-items-center whitespace-nowrap font-iregular text-sm text-white">
            <%= for {link, idx} <- Enum.with_index(footer_links()) do %>
              <!-- In order to properly align links to the right, if there are an odd number of links
                   enabled we need to add a fake cell to the grid in order to create space on the left
                   side of the row and fil it. Otherwise, the links would be left aligned -->
              <div :if={idx == 1 and rem(length(footer_links()), 2) == 1} class="hidden lg:block">
              </div>
              <.link href={link.url} class="block w-full hover:underline text-center lg:text-right">
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
      <div
        :if={@tip != []}
        class="hidden lg:flex flex-col items-center w-full justify-center absolute bottom-0 left-0 overflow-clip pointer-events-none"
      >
        <div class="group flex flex-col items-center justify-center pointer-events-auto">
          <p class="bg-white text-black text-center p-2 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity">
            <%= render_slot(@tip) %>
          </p>
          <img
            src={~p"/images/star-struck-void.svg"}
            class="w-32 h-32 translate-y-11 group-hover:translate-y-6 transition-transform"
          />
        </div>
      </div>
    </footer>
    """
  end

  defp footer_links do
    [
      %{
        title: "Previous Edition",
        url: "https://2024.seium.org/",
        enabled: true
      },
      %{
        title: "Report a Problem",
        url: "https://cesium.link/f/safira-bugs",
        enabled: true
      },
      %{
        title: "Survival Guide",
        url: "/docs/survival-guide.pdf",
        enabled: Event.get_feature_flag!("survival_guide_enabled")
      },
      %{
        title: "General Regulation",
        url: "/docs/regulation.pdf",
        enabled: Event.get_feature_flag!("general_regulation_enabled")
      },
      %{
        title: "Privacy Policy",
        url: "/docs/privacy_policy.pdf",
        enabled: true
      }
    ]
    |> Enum.filter(fn x -> x.enabled end)
  end
end
