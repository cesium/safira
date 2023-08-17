defmodule SafiraWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use SafiraWeb, :controller
      use SafiraWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def controller(version \\ "1.7") do
    result =
      case version do
        "1.7" ->
          quote do
            use Phoenix.Controller,
              namespace: SafiraWeb,
              formats: [:html, :json],
              layouts: [html: SafiraWeb.Layouts]

            unquote(verified_routes())
          end

        _ ->
          quote do
            use Phoenix.Controller, namespace: SafiraWeb
            alias SafiraWeb.Router.Helpers, as: Routes
          end
      end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/safira_web/templates",
        namespace: SafiraWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SafiraWeb.ErrorHelpers
      import SafiraWeb.Gettext
      alias SafiraWeb.Router.Helpers, as: Routes

      unquote(verified_routes())
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SafiraWeb.Gettext
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: SafiraWeb.Endpoint,
        router: SafiraWeb.Router,
        statics: SafiraWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """

  defmacro __using__(controller: "1.6" = version) do
    controller(version)
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
