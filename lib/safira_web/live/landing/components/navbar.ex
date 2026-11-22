defmodule SafiraWeb.Landing.Components.Navbar do
  @moduledoc false
  use SafiraWeb, :component

  import SafiraWeb.Components.{Avatar, Dropdown}
  import SafiraWeb.Landing.Components.JoinUs

  attr :pages, :list, default: []
  attr :registrations_open?, :boolean, default: false
  attr :current_user, :map, default: nil
  attr :current_page, :atom, default: nil
  attr :class, :any, default: nil

  def navbar(assigns) do
    ~H"""
    <div class={@class}>
      <nav class="flex h-16 items-center justify-between pt-8 pb-4 px-10 md:px-15 box-content">
        <.link href="/" class="select-none">
          <img src="/images/sei-logo.svg" alt="SEI Logo" class="h-8 w-auto" />
        </.link>

        <div class="hidden lg:flex items-center gap-12 select-none">
          <.link
            :if={!@current_user}
            navigate={~p"/users/log_in"}
            class="text-sm text-white transition-colors duration-75 ease-in hover:text-accent text-nowrap"
          >
            Log in
          </.link>
          <.join_us :if={@registrations_open? && !@current_user} />
          <.dropdown :if={@current_user}>
            <:trigger_element>
              <.avatar
                handle={@current_user.handle}
                src={
                  Uploaders.UserPicture.url(
                    {@current_user.picture, @current_user},
                    :original,
                    signed: true
                  )
                }
                size={:sm}
                class="ring-2 rounded-full ring-white"
              />
            </:trigger_element>
            <.dropdown_menu_item
              :if={user_type?(@current_user, :staff)}
              link_type="a"
              to="/dashboard/scanner"
              label="Dashboard"
            />
            <.dropdown_menu_item
              :if={user_type?(@current_user, :attendee)}
              link_type="a"
              to={
                if @current_user.confirmed_at,
                  do: "/app",
                  else: "/users/confirmation_pending"
              }
              label="App"
            />
            <.dropdown_menu_item
              :if={user_type?(@current_user, :company)}
              link_type="a"
              to="/sponsor/scanner"
              label="Scanner"
            />
            <.dropdown_menu_item
              link_type="a"
              method="delete"
              to="/users/log_out"
              label="Sign Out"
            />
          </.dropdown>
        </div>

        <span class="cursor-pointer lg:hidden" phx-click={show_mobile_navbar()}>
          <.icon name="hero-bars-3" />
        </span>
      </nav>
      <nav
        :if={@pages != []}
        class="fixed inset-x-0 bottom-0 z-30 hidden lg:flex justify-center pt-12.5 pb-12.5 bg-radial-[100%_100%_at_bottom] from-black/80 to-transparent select-none pointer-events-none"
      >
        <div
          aria-hidden="true"
          class="absolute inset-0 -z-10 backdrop-blur-xs mask-t-from-50%"
        >
        </div>
        <.link
          :if={@current_page != :home}
          navigate={~p"/"}
          class="pointer-events-auto absolute bottom-12.5 left-10 md:left-15 flex items-center gap-2 font-pixel text-base text-white opacity-80 transition-colors duration-75 ease-in hover:text-accent"
        >
          <.icon name="hero-arrow-left-mini" class="size-4" /> Back to homepage
        </.link>
        <.link
          id="hero-scroll-link"
          href="#about"
          phx-hook="HeroScrollLink"
          data-hidden
          inert
          phx-mounted={JS.ignore_attributes(["data-hidden", "inert"])}
          class="group pointer-events-auto grid grid-cols-[1fr] opacity-80 transition-[grid-template-columns] duration-500 ease-in-out data-hidden:grid-cols-[0fr]"
        >
          <span class="min-w-0">
            <span class="flex items-center gap-2 whitespace-nowrap pr-8.75 font-pixel text-base text-white transition duration-500 ease-in-out group-hover:text-accent group-data-hidden:translate-x-full group-data-hidden:opacity-0">
              Scroll to discover more <.icon name="hero-arrow-down-mini" class="size-4" />
            </span>
          </span>
        </.link>
        <div class="relative z-10 flex gap-8.75">
          <.link
            :for={page <- @pages}
            navigate={page.url}
            aria-current={page.key == @current_page && "page"}
            class={[
              "pointer-events-auto font-pixel text-base text-white transition-colors duration-75 ease-in",
              if(page.key == @current_page,
                do:
                  "relative after:absolute after:inset-x-0 after:-bottom-2 after:h-1 after:rounded-full after:bg-white/60 after:blur-sm",
                else: "opacity-70 hover:text-accent"
              )
            ]}
          >
            {page.title}
            <.icon
              :if={page.key == @current_page}
              name="fa-circle-solid"
              class="absolute -bottom-2.5 left-1/2 size-1.5 -translate-x-1/2"
            />
          </.link>
        </div>
      </nav>
      <div
        id="mobile-navbar"
        class="bg-primary w-full h-dvh overflow-y-auto absolute top-0 left-0 bottom-0 z-40 flex flex-col"
        style="display: none;"
      >
        <div class="w-full flex flex-col items-end px-10 py-12">
          <span class="cursor-pointer" phx-click={hide_mobile_navbar()}>
            <.icon name="hero-x-mark" />
          </span>
        </div>
        <div class="flex flex-col w-full items-center gap-16 mb-16">
          <%= for page <- @pages do %>
            <.link
              navigate={page.url}
              phx-click={hide_mobile_navbar()}
              class="font-pixel uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
            >
              {page.title}
            </.link>
          <% end %>
          <.link
            :if={!@current_user}
            navigate={~p"/users/log_in"}
            phx-click={hide_mobile_navbar()}
            class="font-pixel uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
          >
            Log in
          </.link>
          <div :if={@registrations_open? && !@current_user} class="flex">
            <.join_us />
          </div>
          <.link
            :if={user_type?(@current_user, :staff)}
            patch={~p"/dashboard/scanner"}
            phx-click={hide_mobile_navbar()}
            class="font-pixel uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
          >
            Dashboard
          </.link>
          <.link
            :if={user_type?(@current_user, :attendee)}
            patch={~p"/app"}
            phx-click={hide_mobile_navbar()}
            class="font-pixel uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
          >
            App
          </.link>
          <.link
            :if={user_type?(@current_user, :company)}
            patch={~p"/sponsor/scanner"}
            phx-click={hide_mobile_navbar()}
            class="font-pixel uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
          >
            Scanner
          </.link>
          <.link
            :if={@current_user}
            method="delete"
            href={~p"/users/log_out"}
            phx-click={hide_mobile_navbar()}
            class="font-pixel uppercase text-3xl text-white transition-colors duration-75 ease-in hover:text-accent"
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
    |> JS.add_class("overflow-hidden", to: "body")
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
    |> JS.remove_class("overflow-hidden", to: "body")
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
