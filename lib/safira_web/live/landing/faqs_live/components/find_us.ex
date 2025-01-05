defmodule SafiraWeb.Landing.FAQLive.Components.FindUs do
  @moduledoc false
  use SafiraWeb, :component

  @email "cesium@di.uminho.pt"
  @tel "+351 253 604 448"

  def find_us(assigns) do
    ~H"""
    <section class="spacing flex flex-col py-20 lg:flex-row lg:justify-between">
      <div class="z-40 mb-10 mr-10 flex flex-col text-white">
        <h2 class="font-terminal uppercase mb-2 select-none text-6xl font-bold">
          <%= gettext("How to find us") %>
        </h2>

        <p class="mb-8 font-iregular">
          <%= gettext(
            "SEI is free for participants and is organized by volunteers from CeSIUM and from the university community."
          ) %>
        </p>
        <.link href="https://whereis.uminho.pt/CG-02.html" target="_blank" class="mb-8 font-iregular">
          <%= gettext("This year's event will take place at Pedagogic Complex 2, Gualtar Campus.") %>
        </.link>
        <p class="mb-2 font-ibold">
          Centro de Estudantes de Engenharia Informática
        </p>
        <ul class="list-inside list-disc font-iregular">
          <.link href={"mailto:#{email()}"}>
            <li>E-mail: <%= email() %></li>
          </.link>
          <.link href={"tel:#{tel()}"}>
            <li>Phone: <%= tel() %></li>
          </.link>
        </ul>
      </div>
      <div class="w-full select-none lg:w-3/5">
        <img src={~p"/images/map/location.svg"} alt="" />
      </div>
    </section>
    """
  end

  defp email do
    @email
  end

  defp tel do
    @tel
  end
end
