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
    <li id={@id} class="flex flex-row items-center justify-center">
      <.link href={"/attendees/#{@id}"}>
        <div class="py-4 px-4">
          <img class="w-16 h-16 m-auto" src={@image} />
          <h1 class="font-terminal uppercase text-xl">
            <%= @name %>
          </h1>
        </div>
      </.link>
    </li>
    """
  end
end
