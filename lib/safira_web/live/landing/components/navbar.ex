defmodule SafiraWeb.Landing.Components.Navbar do
  @moduledoc false
  use SafiraWeb, :component

  import SafiraWeb.Landing.Components.JoinUs

  attr :pages, :list, default: []

  def navbar(assigns) do
    ~H"""
    <div>
      <nav class="pt-8 pb-4 xl:px-[15rem] md:px-[8rem] px-[2.5rem]">
        <div class="flex h-16 items-center justify-between">
          <div class="relative flex flex-auto">
            <div class="flex w-full justify-between">
              <.link href="/">
                <div class="block select-none h-full">
                  <img
                    src="/images/sei-logo.svg"
                    width={50}
                    alt="SEI Logo"
                    class="cursor-pointer transition-colors duration-75 ease-in hover:text-accent h-full"
                  />
                </div>
              </.link>
              <div class="col-span-3 hidden justify-self-end lg:block">
                <div class="flex select-none items-center h-full">
                  <div class="flex flex-row gap-12">
                    <%= for page <- @pages do %>
                      <.link
                        patch={page.url}
                        class="text-sm text-white transition-colors duration-75 ease-in hover:text-accent"
                      >
                        <%= page.title %>
                      </.link>
                    <% end %>
                  </div>
                  <div class="flex pl-20">
                    <.join_us />
                  </div>
                </div>
              </div>
              <div class="block lg:hidden">
                <span class="cursor-pointer" phx-click={show_mobile_navbar()}>
                  <.icon name="hero-bars-3" />
                </span>
              </div>
            </div>
          </div>
        </div>
      </nav>
      <div
        id="mobile-navbar"
        class="bg-primary w-full h-screen absolute top-0 left-0 bottom-0 z-40 flex flex-col"
        style="display: none;"
      >
        <div class="w-full flex flex-col items-end px-10 py-12">
          <span class="cursor-pointer" phx-click={hide_mobile_navbar()}>
            <.icon name="hero-x-mark" />
          </span>
        </div>
        <div class="flex flex-col w-full items-center gap-16">
          <%= for page <- @pages do %>
            <.link
              patch={page.url}
              class="font-terminal uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
            >
              <%= page.title %>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def show_mobile_navbar(js \\ %JS{}) do
    js
    |> JS.show(to: "#mobile-navbar-container", transition: "fade-in")
    |> JS.show(
      to: "#mobile-navbar",
      display: "flex",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"}
    )
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.hide(to: "#show-mobile-navbar", transition: "fade-out")
    |> JS.dispatch("js:call", to: "#hide-mobile-navbar", detail: %{call: "focus", args: []})
  end

  def hide_mobile_navbar(js \\ %JS{}) do
    js
    |> JS.hide(to: "#mobile-navbar-container", transition: "fade-out")
    |> JS.hide(
      to: "#mobile-navbar",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"}
    )
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.show(to: "#show-mobile-navbar", transition: "fade-in")
    |> JS.dispatch("js:call", to: "#show-mobile-navbar", detail: %{call: "focus", args: []})
  end
end
