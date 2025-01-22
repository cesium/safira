defmodule SafiraWeb.Landing.Components.Footer do
  @moduledoc """
  Footer component.
  """
  use SafiraWeb, :component
  import SafiraWeb.Landing.Components.Socials

  alias Safira.Event

  def footer(assigns) do
    ~H"""
    <footer class="xl:px-[15rem] md:px-[8rem] px-[2.5rem]">
      <div class="flex flex-col justify-between gap-16 py-10 lg:flex-row">
        <div class="flex select-none items-start justify-center lg:justify-start">
          <img src="/images/sei-logo.svg" width={100} height={100} alt="SEI Logo" />
          <p class="pl-6 text-white font-semibold lg:flex-1">
            Semana da <br /> Engenharia <br /> Informática
          </p>
        </div>

        <div class="flex-2">
          <div class="w-full flex flex-wrap flex-row-reverse select-none justify-items-center whitespace-nowrap font-iregular text-sm text-white">
            <%= for link <- footer_links() do %>
              <.link
                href={link.url}
                class="flex grow w-full lg:w-1/2 py-4 pl-4 hover:underline justify-center lg:justify-end"
              >
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
