defmodule SafiraWeb.Backoffice.MinigamesLive.Index do
  use SafiraWeb, :backoffice_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :minigames)}
  end

  def handle_params(_, _params, socket) do
    {:noreply, socket}
  end
end
