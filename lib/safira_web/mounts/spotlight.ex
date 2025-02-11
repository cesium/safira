defmodule SafiraWeb.Spotlight do
  @moduledoc """
    This module is for Spotlight
  """
  use SafiraWeb, :verified_routes

  import Phoenix.LiveView
  use Phoenix.Component

  alias Safira.Spotlights
  alias Safira.Spotlights.Spotlight

  def on_mount(:fetch_current_spotlight, _params, _session, socket) do
    if connected?(socket) do
      Spotlights.subscribe_to_spotlight_event()
    end

    {:cont,
     socket
     |> assign(:current_spotlight, Spotlights.get_current_spotlight())
     |> attach_hook(:spotlight_updated, :handle_info, fn
       %Spotlight{} = spotlight, socket ->
         {:halt, socket |> assign(:current_spotlight, spotlight)}

       _params, socket ->
         {:cont, socket}
     end)}
  end

  def handle_info(%Spotlight{} = spotlight, socket) do
    {:cont, socket |> assign(:current_spotlight, spotlight)}
  end
end
