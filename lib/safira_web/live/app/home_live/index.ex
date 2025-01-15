defmodule SafiraWeb.App.HomeLive.Index do
  use SafiraWeb, :app_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("on_spotlight_end", %{}, socket) do
    {:noreply, socket |> push_navigate(to: "/app")}
  end
end
