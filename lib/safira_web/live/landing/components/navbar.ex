defmodule SafiraWeb.Landing.Components.Navbar do
  @moduledoc false
  use SafiraWeb, :component

  import SafiraWeb.Components.{Avatar, Dropdown}
  import SafiraWeb.Landing.Components.JoinUs

  attr :pages, :list, default: []
  attr :registrations_open?, :boolean, default: false
  attr :current_user, :map, default: nil

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
                  <div :if={@registrations_open? && !@current_user} class="flex pl-20">
                    <.join_us />
                  </div>
                  <div :if={@current_user} class="flex pl-16">
                    <.dropdown>
                      <:trigger_element>
                        <.avatar
                          handle={@current_user.handle}
                          size={:sm}
                          class="ring-2 rounded-full ring-white"
                        />
                      </:trigger_element>
                      <.dropdown_menu_item
                        :if={user_type?(@current_user, :staff)}
                        link_type="live_patch"
                        to="/dashboard/attendees"
                        label="Dashboard"
                      />
                      <.dropdown_menu_item
                        :if={user_type?(@current_user, :attendee)}
                        link_type="live_patch"
                        to={if @current_user.confirmed_at, do: "/app", else: "/users/confirmation_pending"}
                        label="App"
                      />
                      <.dropdown_menu_item
                        link_type="a"
                        method="delete"
                        to="/users/log_out"
                        label="Sign Out"
                      />
                    </.dropdown>
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
              phx-click={hide_mobile_navbar()}
              class="font-terminal uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
            >
              <%= page.title %>
            </.link>
          <% end %>
          <div :if={@registrations_open? && !@current_user} class="flex">
            <.join_us />
          </div>
          <.link
            :if={user_type?(@current_user, :staff)}
            patch={~p"/dashboard/attendees"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
          >
            Dashboard
          </.link>
          <.link
            :if={user_type?(@current_user, :attendee)}
            patch={~p"/app"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
          >
            App
          </.link>
          <.link
            :if={@current_user}
            method="delete"
            href={~p"/users/log_out"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
          >
            Sign Out
          </.link>
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

  defp user_type?(user, type) do
    user && user.type == type
  end
end
