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
      class="fixed inset-0 z-40 flex lg:hidden"
      aria-modal="true"
      style="display: none;"
    >
      <div
        id="sidebar-overlay"
        class="fixed inset-0 h-full min-h-screen bg-gray-800 bg-opacity-55 backdrop-blur-sm"
        phx-click={hide_mobile_sidebar()}
      >
      </div>
      <div
        id="mobile-sidebar"
        class={"relative flex-1 flex flex-col max-w-xs w-full pt-5 pb-4 #{@background} rounded-r-lg h-dvh"}
      >
        <div class="flex flex-col flex-1 py-4 overflow-y-auto scrollbar-hide">
          <.link navigate={@logo_url} class={"flex items-center shrink-0 #{@logo_padding}"}>
            <img class="hidden w-full h-full dark:block" src={@logo_images.light} />
            <img class="w-full h-full dark:hidden" src={@logo_images.dark} />
          </.link>
          <div class="flex flex-col justify-between h-full mt-8">
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
    <div class="hidden lg:flex lg:shrink-0">
      <div class={"flex flex-col w-64 border-r #{@border} #{@background} pt-5"}>
        <.link navigate={@logo_url} class={"flex items-center shrink-0 #{@logo_padding}"}>
          <img class="hidden w-full h-full dark:block" src={@logo_images.light} />
          <img class="w-full h-full dark:hidden" src={@logo_images.dark} />
        </.link>
        <!-- Sidebar component, swap this element with another sidebar if you like -->
        <div class="flex flex-col justify-between flex-1 h-0 pb-4 overflow-y-auto scrollbar-hide">
          <!-- Navigation -->
          <nav class="pr-4 mt-6">
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

  attr :pages, :list, default: []
  attr :current_user, :map, required: false
  attr :current_page, :atom, default: nil
  attr :border, :string, default: ""
  attr :logo_url, :string, default: "/"
  attr :logo_images, :map, required: true
  attr :user_dropdown_name_color, :string, default: ""
  attr :user_dropdown_handle_color, :string, default: ""
  attr :user_dropdown_icon_color, :string, default: ""
  attr :link_active_class, :string, default: ""
  attr :link_inactive_class, :string, default: ""

  def app_sidebar(assigns) do
    dock_items = app_dock_items(assigns.pages, assigns.current_user)

    assigns =
      assigns
      |> assign(:dock_items, dock_items)
      |> assign(:active_index, Enum.find_index(dock_items, &(&1.key == assigns.current_page)))

    ~H"""
    <div class="fixed inset-x-0 bottom-0 z-40 px-4 pb-4 lg:hidden">
      <nav class="mx-auto w-full max-w-sm rounded-full bg-white/5 backdrop-blur-lg border border-white/20 shadow-lg p-2">
        <div
          id="app-dock"
          phx-hook="Dock"
          data-active={@active_index}
          style={"--dock-active: #{@active_index || 0}; --dock-items: #{length(@dock_items)}"}
          class="relative grid grid-flow-col auto-cols-fr"
        >
          <span
            :if={@active_index}
            aria-hidden="true"
            class="absolute inset-y-0 left-0 w-[calc(100%/var(--dock-items))] translate-x-[calc(var(--dock-active)*100%)] rounded-full bg-white/10 border border-white/15 shadow-[inset_0_1px_0_0_rgb(255_255_255/0.1)] transition-transform duration-500 ease-[cubic-bezier(0.34,1.4,0.64,1)] motion-reduce:transition-none"
          />

          <.link
            :for={{item, index} <- Enum.with_index(@dock_items)}
            navigate={item.url}
            aria-label={item.title}
            aria-current={index == @active_index && "page"}
            class="relative flex h-14 items-center justify-center"
          >
            <.icon :if={item[:icon]} name={item.icon} class={dock_icon_class(index == @active_index)} />
            <div
              :if={item[:image]}
              class={["bg-current", dock_icon_class(index == @active_index)]}
              style={"mask: url(#{item.image}) no-repeat center / contain; -webkit-mask: url(#{item.image}) no-repeat center / contain;"}
            />
          </.link>
        </div>
      </nav>
    </div>

    <!-- Static sidebar for desktop -->
    <div class="hidden lg:flex lg:shrink-0">
      <div class={"flex flex-col w-64 border-r #{@border} bg-primary pt-5"}>
        <.link navigate={@logo_url} class="flex items-center shrink-0 px-16 pt-4 pb-4">
          <img class="hidden w-full h-full dark:block" src={@logo_images.light} />
          <img class="w-full h-full dark:hidden" src={@logo_images.dark} />
        </.link>

        <div class="flex flex-col justify-between flex-1 h-0 overflow-y-auto scrollbar-hide">
          <nav class="mt-6">
            <%= if @current_user do %>
              <.sidebar_nav_links
                user={@current_user}
                pages={@pages}
                current_page={@current_page}
                link_class="px-4 group flex items-center py-2 font-medium transition-colors"
                link_active_class={@link_active_class}
                link_inactive_class={@link_inactive_class}
              />
            <% end %>
          </nav>
          <%= if @current_user do %>
            <.app_sidebar_account_dropdown
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
  attr :border, :string, default: ""
  attr :title_color, :string, default: ""
  attr :subtitle_color, :string, default: ""
  attr :icon_color, :string, default: ""

  def app_sidebar_account_dropdown(assigns) do
    user = assigns.user

    assigns = assigns |> Map.put(:base_path, get_base_path_by_user_type(user))

    ~H"""
    <.app_user_dropdown id={@id} border={@border} icon_color={@icon_color} user={@user}>
      <:title color={@title_color}>{@user.name}</:title>
      <:subtitle color={@subtitle_color}>@{@user.handle}</:subtitle>
      <:link navigate={"/app/user/#{@user.handle}"}>Profile</:link>
      <:link navigate={"/#{@base_path}/profile_settings"}>Settings</:link>
      <:link href="/users/log_out" method={:delete}>Sign out</:link>
    </.app_user_dropdown>
    """
  end

  attr :id, :string, required: true
  attr :border, :string, default: ""
  attr :icon_color, :string, default: ""

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

  defp app_user_dropdown(assigns) do
    ~H"""
    <!-- User account dropdown -->
    <div class="relative inline-block">
      <div>
        <button
          id={@id}
          type="button"
          class={"group w-full #{@border} cursor-pointer hover:bg-light/5 border-t px-3.5 py-6 text-sm text-left font-medium text-gray-700 transition-all duration-200"}
          phx-click={show_user_dropdown("##{@id}-dropdown")}
          data-active-class=""
          aria-haspopup="true"
        >
          <span class={"flex w-full justify-between items-center #{@icon_color}"}>
            <span class="flex items-center justify-between min-w-0 space-x-3">
              <.avatar
                size={:sm}
                handle={@user.handle}
                src={Uploaders.UserPicture.url({@user.picture, @user}, :original, signed: true)}
              />
              <span class="flex flex-col flex-1 min-w-0">
                <span class={"#{@title |> Enum.at(0) |> Map.get(:color)}  text-sm font-medium truncate"}>
                  {render_slot(@title)}
                </span>
                <span class={"#{@subtitle |> Enum.at(0) |> Map.get(:color)} text-sm truncate"}>
                  {render_slot(@subtitle)}
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
        class="absolute left-0 right-0 z-10 hidden border-light/10 mb-2 overflow-hidden origin-bottom shadow-lg bottom-full border bg-primary"
        role="menu"
        aria-labelledby={@id}
      >
        <div role="none" class="divide-y divide-light/10">
          <%= for link <- @link do %>
            <.link
              tabindex="-1"
              role="menuitem"
              class="block px-4 py-3 font-medium transition-colors bg-light/5 text-white hover:bg-accent/20"
              {link}
            >
              {render_slot(link)}
            </.link>
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
    <div class="space-y-1 z-14">
      <%= for page <- @pages do %>
        <.link
          navigate={page.url}
          class={[
            @link_class,
            @current_page != page.key && @link_inactive_class,
            @current_page == page.key && @link_active_class
          ]}
        >
          <%= if Map.get(page, :icon) do %>
            <.icon name={page.icon} class="shrink-0 mr-3 size-6" />
          <% end %>
          <%= if Map.get(page, :image) do %>
            <div
              src={page.image}
              class={[
                "mr-3 shrink-0 size-6 bg-white",
                @current_page != page.key && "bg-white/70"
              ]}
              style={"mask: url(#{page.image}) no-repeat center / contain; -webkit-mask: url(#{page.image}) no-repeat center / contain;"}
            />
          <% end %>
          {page.title}
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
      <:title color={@title_color}>{@user.name}</:title>
      <:subtitle color={@subtitle_color}>@{@user.handle}</:subtitle>
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
    <div class="relative inline-block px-3 mt-6 text-left">
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
            <span class="flex items-center justify-between min-w-0 space-x-3">
              <.avatar
                size={:sm}
                handle={@user.handle}
                src={Uploaders.UserPicture.url({@user.picture, @user}, :original, signed: true)}
              />
              <span class="flex flex-col flex-1 min-w-0">
                <span class={"#{@title |> Enum.at(0) |> Map.get(:color)}  text-sm font-medium truncate"}>
                  {render_slot(@title)}
                </span>
                <span class={"#{@subtitle |> Enum.at(0) |> Map.get(:color)} text-sm truncate"}>
                  {render_slot(@subtitle)}
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
        class="absolute left-0 right-0 z-10 hidden mx-3 mt-1 origin-bottom border divide-y rounded-md shadow-lg bottom-full bg-light dark:bg-dark ring-1 ring-black/5 divide-lightShade dark:divide-darkShade border-lightShade dark:border-darkShade"
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
              {render_slot(link)}
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def show_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.show(
      to: "#mobile-sidebar-container",
      transition: {"transition fade-in duration-200", "opacity-0", "opacity-100"}
    )
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
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.hide(
      to: "#mobile-sidebar-container",
      transition: {"transition fade-out duration-200", "opacity-100", "opacity-0"}
    )
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
        {"transition ease-out duration-100", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"}
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: to)
  end

  defp hide_user_dropdown(to) do
    JS.hide(
      to: to,
      transition:
        {"transition ease-in duration-100", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
    |> JS.remove_attribute("aria-expanded", to: to)
  end

  defp app_dock_items(pages, user) do
    dock_pages =
      [:home, :badges, :games, :store]
      |> Enum.map(fn key -> Enum.find(pages, &(&1.key == key)) end)
      |> Enum.reject(&is_nil/1)

    if user do
      dock_pages ++
        [%{key: :profile, title: "Profile", url: "/app/user/#{user.handle}", icon: "hero-user"}]
    else
      dock_pages
    end
  end

  # The active icon fades in from the inactive look (`starting:`) when the page renders
  defp dock_icon_class(true) do
    "size-7 text-accent scale-110 starting:text-white starting:scale-100 " <>
      "transition duration-300 motion-reduce:transition-none"
  end

  defp dock_icon_class(false), do: "size-7 text-white"
end
