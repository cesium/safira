defmodule SafiraWeb.Backoffice.ProductLive.View do
  use SafiraWeb, :backoffice_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket|> assign(:current_page, :view)}
  end


end
