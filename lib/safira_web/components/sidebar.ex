defmodule SafiraWeb.Components.Sidebar do
  use SafiraWeb, :component

  import SafiraWeb.CoreComponents
  alias SafiraWeb.Config
  alias Phoenix.LiveView.JS

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
        class="relative flex-1 flex flex-col max-w-xs w-full pt-5 pb-4 bg-light dark:bg-dark hidden min-h-screen h-full"
      >
        <div class="flex-1 flex flex-col py-4 overflow-y-auto scrollbar-hide">
          <div class="flex-shrink-0 flex items-center pt-4">
            <.link navigate={}>
              <div class="flex items-center px-8">
                <.link navigate={~p"/"}>
                  <img
                    class="w-full h-full hidden dark:block"
                    src={~p"/images/safira-light.svg"}
                    width="36"
                    height="36"
                  />
                  <img class="w-full h-full dark:hidden" src={~p"/images/safira-dark.svg"} />
                </.link>
              </div>
            </.link>
          </div>
          <div class="mt-8 flex flex-col justify-between h-full">
            <nav class="px-4">
              <%= if @current_user do %>
                <.sidebar_nav_links user={@current_user} current_page={@current_page} />
              <% end %>
            </nav>
            <%= if @current_user do %>
              <.sidebar_account_dropdown id="mobile-account-dropdown" user={@current_user} />
            <% end %>
          </div>
        </div>
      </div>

      <div class="flex-shrink-0 w-14" aria-hidden="true">
        <!-- Dummy element to force sidebar to shrink to fit close icon -->
      </div>
    </div>
    <!-- Static sidebar for desktop -->
    <div class="hidden lg:flex lg:flex-shrink-0">
      <div class="flex flex-col w-64 border-r border-r-lightShade dark:border-r-darkShade pt-5 bg-light dark:bg-dark">
        <div class="flex items-center flex-shrink-0 px-8 pt-8 pb-4">
          <.link navigate={~p"/"}>
            <img
              class="w-full h-full hidden dark:block"
              src={~p"/images/safira-light.svg"}
              width="36"
              height="36"
            />
            <img
              class="w-full h-full dark:hidden"
              src={~p"/images/safira-dark.svg"}
              width="36"
              height="36"
            />
          </.link>
        </div>
        <!-- Sidebar component, swap this element with another sidebar if you like -->
        <div class="h-0 flex-1 flex flex-col justify-between pb-4 overflow-y-auto scrollbar-hide">
          <!-- Navigation -->
          <nav class="px-4 mt-6">
            <%= if @current_user do %>
              <.sidebar_nav_links user={@current_user} current_page={@current_page} />
            <% end %>
          </nav>
          <%= if @current_user do %>
            <.sidebar_account_dropdown id="account-dropdown" user={@current_user} />
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

  def sidebar_nav_links(assigns) do
    ~H"""
    <div class="space-y-1">
      <%= for page <- Config.backoffice_pages() do %>
        <.link
          navigate={page.url}
          class={[
            "px-3 dark:hover:bg-darkShade group flex items-center py-2 text-sm font-medium rounded-md transition-colors",
            @current_page != page.key && "text-dark hover:bg-lightShade/40 dark:text-light",
            @current_page == page.key && "bg-dark text-light hover:bg-darkShade dark:bg-darkShade"
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

  def sidebar_account_dropdown(assigns) do
    ~H"""
    <.dropdown id={@id}>
      <:img src={"https://github.com/identicons/#{@user.handle |> String.slice(0..2)}.png"} />
      <:title><%= @user.name %></:title>
      <:subtitle>@<%= @user.handle %></:subtitle>
      <:link navigate="/profile/settings">Settings</:link>
      <:link href="/users/log_out" method={:delete}>Sign out</:link>
    </.dropdown>
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
end
