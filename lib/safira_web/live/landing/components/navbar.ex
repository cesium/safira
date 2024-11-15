defmodule SafiraWeb.Landing.Components.Navbar do
  @moduledoc false
  use SafiraWeb, :component

  import SafiraWeb.Landing.Components.JoinUs

  attr :pages, :list, default: []

  def navbar(assigns) do
    ~H"""
    <nav class="pt-8 pb-4 xl:px-[15rem] md:px-[8rem] px-[2.5rem]">
      <div class="flex h-16 items-center justify-between">
        <div class="relative flex flex-auto">
          <div class="grid w-full grid-cols-4">
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
          </div>
        </div>
      </div>
    </nav>
    """
  end
end
