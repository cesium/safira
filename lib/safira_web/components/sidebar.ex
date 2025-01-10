defmodule SafiraWeb.Components.Sidebar do
  @moduledoc """
  Sidebar component for the application layout.
  """
  use SafiraWeb, :component

  import SafiraWeb.CoreComponents
  import SafiraWeb.Components.Avatar
  alias Phoenix.LiveView.JS

  attr :pages, :list, default: []
  attr :current_user, :map, required: false
  attr :current_page, :atom, default: nil
  attr :background, :string, default: ""
  attr :border, :string, default: ""
  attr :logo_padding, :string, default: ""
  attr :logo_url, :string, default: "/"
  attr :logo_images, :map, required: true
  attr :user_dropdown_name_color, :string, default: ""
  attr :user_dropdown_handle_color, :string, default: ""
  attr :user_dropdown_icon_color, :string, default: ""
  attr :link_class, :string, default: ""
  attr :link_active_class, :string, default: ""
  attr :link_inactive_class, :string, default: ""

  def sidebar(assigns) do
    ~H"""
    <div
      id="mobile-sidebar-container"
      class="fixed inset-0 flex z-40 lg:hidden"
      aria-modal="true"
      style="display: none;"
    >
      <div class="fixed inset-0 bg-gray-600 bg-opacity-75" phx-click={hide_mobile_sidebar()}></div>

      <div
        id="mobile-sidebar"
        class={"relative flex-1 flex flex-col max-w-xs w-full pt-5 pb-4 #{@background} hidden min-h-screen h-full"}
      >
        <div class="flex-1 flex flex-col py-4 overflow-y-auto scrollbar-hide">
          <.link navigate={@logo_url} class={"flex items-center flex-shrink-0 #{@logo_padding}"}>
            <img class="w-full h-full hidden dark:block" src={@logo_images.light} />
            <img class="w-full h-full dark:hidden" src={@logo_images.dark} />
          </.link>
          <div class="mt-8 flex flex-col justify-between h-full">
            <nav class="px-4">
              <%= if @current_user do %>
                <.sidebar_nav_links
                  user={@current_user}
                  pages={@pages}
                  current_page={@current_page}
                  link_class={@link_class}
                  link_active_class={@link_active_class}
                  link_inactive_class={@link_inactive_class}
                />
              <% end %>
            </nav>
            <%= if @current_user do %>
              <.sidebar_account_dropdown
                id="mobile-account-dropdown"
                user={@current_user}
                border={@border}
                title_color={@user_dropdown_name_color}
                subtitle_color={@user_dropdown_handle_color}
                icon_color={@user_dropdown_icon_color}
              />
            <% end %>
          </div>
        </div>
      </div>
    </div>
    <!-- Static sidebar for desktop -->
    <div class="hidden lg:flex lg:flex-shrink-0">
      <div class={"flex flex-col w-64 border-r #{@border} #{@background} pt-5"}>
        <.link navigate={@logo_url} class={"flex items-center flex-shrink-0 #{@logo_padding}"}>
          <img class="w-full h-full hidden dark:block" src={@logo_images.light} />
          <img class="w-full h-full dark:hidden" src={@logo_images.dark} />
        </.link>
        <!-- Sidebar component, swap this element with another sidebar if you like -->
        <div class="h-0 flex-1 flex flex-col justify-between pb-4 overflow-y-auto scrollbar-hide">
          <!-- Navigation -->
          <nav class="px-4 mt-6">
            <%= if @current_user do %>
              <.sidebar_nav_links
                user={@current_user}
                pages={@pages}
                current_page={@current_page}
                link_class={@link_class}
                link_active_class={@link_active_class}
                link_inactive_class={@link_inactive_class}
              />
            <% end %>
          </nav>
          <%= if @current_user do %>
            <.sidebar_account_dropdown
              id="account-dropdown"
              user={@current_user}
              border={@border}
              title_color={@user_dropdown_name_color}
              subtitle_color={@user_dropdown_handle_color}
              icon_color={@user_dropdown_icon_color}
            />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :id, :string
  attr :user, :any
  attr :active_tab, :atom
  attr :current_page, :atom, default: nil
  attr :pages, :list, default: []
  attr :link_class, :string, default: ""
  attr :link_active_class, :string, default: ""
  attr :link_inactive_class, :string, default: ""

  def sidebar_nav_links(assigns) do
    ~H"""
    <div class="space-y-1">
      <%= for page <- @pages do %>
        <.link
          navigate={page.url}
          class={[
            @link_class,
            @current_page != page.key && @link_inactive_class,
            @current_page == page.key && @link_active_class
          ]}
        >
          <.icon name={page.icon} class="mr-3 flex-shrink-0 h-6 w-6" /> <%= page.title %>
        </.link>
      <% end %>
    </div>
    """
  end

  attr :id, :string
  attr :user, :any
  attr :border, :string, default: ""
  attr :title_color, :string, default: ""
  attr :subtitle_color, :string, default: ""
  attr :icon_color, :string, default: ""

  def sidebar_account_dropdown(assigns) do
    user = assigns.user

    assigns = assigns |> Map.put(:base_path, get_base_path_by_user_type(user))

    ~H"""
    <.user_dropdown id={@id} border={@border} icon_color={@icon_color} user={@user}>
      <:img src={"https://github.com/identicons/#{@user.handle |> String.slice(0..2)}.png"} />
      <:title color={@title_color}><%= @user.name %></:title>
      <:subtitle color={@subtitle_color}>@<%= @user.handle %></:subtitle>
      <:link navigate={"/#{@base_path}/profile_settings"}>Profile Settings</:link>
      <:link href="/users/log_out" method={:delete}>Sign out</:link>
    </.user_dropdown>
    """
  end

  attr :id, :string, required: true
  attr :border, :string, default: ""
  attr :icon_color, :string, default: ""

  slot :img do
    attr :src, :string
  end

  slot :title do
    attr :color, :string
  end

  slot :subtitle do
    attr :color, :string
  end

  slot :link do
    attr :navigate, :string
    attr :href, :string
    attr :method, :any
  end

  attr :user, :map, required: true

  defp user_dropdown(assigns) do
    ~H"""
    <!-- User account dropdown -->
    <div class="px-3 mt-6 relative inline-block text-left">
      <div>
        <button
          id={@id}
          type="button"
          class={"group w-full rounded-md #{@border} border px-3.5 py-4 text-sm text-left font-medium text-gray-700 dark:hover:bg-dark/20 focus:outline-0 focus:ring-2 focus:ring-offset-2 focus:ring-dark"}
          phx-click={show_user_dropdown("##{@id}-dropdown")}
          data-active-class=""
          aria-haspopup="true"
        >
          <span class={"flex w-full justify-between items-center #{@icon_color}"}>
            <span class="flex min-w-0 items-center justify-between space-x-3">
              <%= for _img <- @img do %>
                <.avatar size={:sm} handle={@user.handle} />
              <% end %>
              <span class="flex-1 flex flex-col min-w-0">
                <span class={"#{@title |> Enum.at(0) |> Map.get(:color)}  text-sm font-medium truncate"}>
                  <%= render_slot(@title) %>
                </span>
                <span class={"#{@subtitle |> Enum.at(0) |> Map.get(:color)} text-sm truncate"}>
                  <%= render_slot(@subtitle) %>
                </span>
              </span>
            </span>
            <.icon name="hero-chevron-up-down" />
          </span>
        </button>
      </div>
      <div
        id={"#{@id}-dropdown"}
        phx-click-away={hide_user_dropdown("##{@id}-dropdown")}
        class="hidden z-10 mx-3 origin-bottom bottom-full absolute right-0 left-0 mt-1 rounded-md shadow-lg bg-light dark:bg-dark ring-1 ring-black ring-opacity-5 divide-y divide-lightShade dark:divide-darkShade border border-lightShade dark:border-darkShade"
        role="menu"
        aria-labelledby={@id}
      >
        <div class="py-1" role="none">
          <%= for link <- @link do %>
            <.link
              tabindex="-1"
              role="menuitem"
              class="block px-4 py-2 text-sm bg-light dark:bg-dark text-dark dark:text-light hover:bg-lightShade/40 dark:hover:bg-darkShade"
              {link}
            >
              <%= render_slot(link) %>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def show_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.show(to: "#mobile-sidebar-container", transition: "fade-in")
    |> JS.show(
      to: "#mobile-sidebar",
      display: "flex",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"}
    )
    |> JS.hide(to: "#show-mobile-sidebar", transition: "fade-out")
    |> JS.dispatch("js:call", to: "#hide-mobile-sidebar", detail: %{call: "focus", args: []})
  end

  def hide_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(to: "#mobile-sidebar-container", transition: "fade-out")
    |> JS.hide(
      to: "#mobile-sidebar",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"}
    )
    |> JS.show(to: "#show-mobile-sidebar", transition: "fade-in")
    |> JS.dispatch("js:call", to: "#show-mobile-sidebar", detail: %{call: "focus", args: []})
  end

  defp show_user_dropdown(to) do
    JS.show(
      to: to,
      transition:
        {"transition ease-out duration-120", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"}
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: to)
  end

  defp hide_user_dropdown(to) do
    JS.hide(
      to: to,
      transition:
        {"transition ease-in duration-120", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
    |> JS.remove_attribute("aria-expanded", to: to)
  end
end
