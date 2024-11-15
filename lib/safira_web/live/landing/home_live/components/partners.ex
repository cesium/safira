defmodule SafiraWeb.Landing.HomeLive.Components.Partners do
  @moduledoc false
  use SafiraWeb, :component

  def partners(assigns) do
    ~H"""
    <div class="spacing w-full bg-secondary pt-20 pb-20">
      <h2 class="font-terminal uppercase select-none py-10 text-center text-5xl text-white lg:text-6xl">
        <%= gettext("Partners who made this possible") %>
      </h2>
      <div class="my-10 flex flex-wrap items-center justify-center gap-10">
        <div
          :for={partner <- event_partners()}
          class="m-auto w-40 select-none grayscale filter transition-all hover:filter-none"
        >
          <.link href={partner.url} target="_blank" rel="noreferrer">
            <img src={"/images/partners/#{partner.logo}"} class="w-full h-40" alt={partner.name} />
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp event_partners do
    [
      %{
        name: "UMinho School of Engineering",
        url: "https://www.eng.uminho.pt",
        logo: "eeum.svg"
      },
      %{
        name: "IPDJ",
        url: "https://ipdj.gov.pt",
        logo: "ipdj.svg"
      }
    ]
  end
end
