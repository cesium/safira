defmodule SafiraWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use SafiraWeb, :controller
      use SafiraWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images docs favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: SafiraWeb.Layouts]

      import Plug.Conn
      use Gettext, backend: SafiraWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {SafiraWeb.Layouts, :default}

      unquote(html_helpers())
    end
  end

  def app_view do
    quote do
      use Phoenix.LiveView,
        layout: {SafiraWeb.Layouts, :app}

      import SafiraWeb.Components.Avatar
      import SafiraWeb.Components.Button

      unquote(html_helpers())
    end
  end

  def backoffice_view do
    quote do
      use Phoenix.LiveView,
        layout: {SafiraWeb.Layouts, :backoffice}

      import SafiraWeb.Components.Avatar
      import SafiraWeb.Components.EnsurePermissions
      import SafiraWeb.BackofficeHelpers

      unquote(html_helpers())
    end
  end

  def landing_view do
    quote do
      use Phoenix.LiveView
      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      import SafiraWeb.Components.Avatar
      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import SafiraWeb.CoreComponents
      import SafiraWeb.Components.Page
      use Gettext, backend: SafiraWeb.Gettext

      import SafiraWeb.Helpers

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())

      alias Safira.Uploaders
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
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
