defmodule SafiraWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use SafiraWeb, :html

  import SafiraWeb.Landing.Components.{Footer, Navbar, Sparkles}

  embed_templates "error_html/*"
end
