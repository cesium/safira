defmodule SafiraWeb.Landing.Components.Socials do
  @moduledoc """
  Event socials component.
  """
  use SafiraWeb, :component

  def socials(assigns) do
    ~H"""
    <ul class="flex items-center gap-4 md:gap-5">
      <li :for={link <- links()} class="flex items-center justify-center">
        <.link
          href={link.url}
          target="_blank"
          class="transition-colors duration-75 ease-in hover:text-accent"
        >
          <.icon name={link.icon} class="w-4 h-4" />
        </.link>
      </li>
    </ul>
    """
  end

  defp links do
    [
      %{
        icon: "fa-brand-instagram",
        url: "https://instagram.com/sei.uminho"
      },
      %{
        icon: "fa-brand-linkedin-in",
        url: "https://linkedin.com/company/sei-cesium"
      },
      %{
        icon: "fa-brand-github",
        url: "https://github.com/cesium/safira"
      },
      %{
        icon: "fa-brand-x-twitter",
        url: "https://x.com/cesiuminho"
      },
      %{
        icon: "fa-brand-facebook",
        url: "https://facebook.com/SEI.UMinho"
      },
      %{
        icon: "fa-brand-discord",
        url: "https://discord.gg/stUtCjsnHx"
      },
      %{
        icon: "hero-envelope-solid",
        url: "mailto:geral@seium.org"
      }
    ]
  end
end
