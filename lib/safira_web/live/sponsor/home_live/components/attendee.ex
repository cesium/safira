defmodule SafiraWeb.Sponsor.HomeLive.Components.Attendee do
  @moduledoc """
  Vault item component.
  """
  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :image, :string, required: true

  def attendee(assigns) do
    ~H"""
    <li id={@id} class="flex flex-row">
      <div class="py-4 px-4">
        <h1 class="font-terminal uppercase text-2xl">
          <%= @name %>
        </h1>
      </div>
    </li>
    """
  end
end
