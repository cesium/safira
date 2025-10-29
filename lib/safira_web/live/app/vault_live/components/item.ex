defmodule SafiraWeb.App.VaultLive.Components.Item do
  @moduledoc """
  Vault item component.
  """
  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :image, :string, required: true
  attr :data, :map, required: true
  attr :redeemed, :boolean, required: true

  def item(assigns) do
    ~H"""
    <li id={@id} class={"flex flex-row #{if @redeemed do "opacity-50" end}"}>
      <figure class="w-32 h-32 bg-light/5 rounded-xl flex-shrink-0">
        <%= if @image do %>
          <img class="w-full p-4" src={@image} />
        <% end %>
      </figure>
      <div class="py-4 px-4">
        <h1 class="font-terminal uppercase text-2xl">
          {@name}
        </h1>
        <p :if={!@redeemed}>
          {gettext("Go to the accreditation to redeem your item!")}
        </p>
        <p :if={@redeemed} class="flex flex-row justify-center items-center">
          <.icon name="hero-check" class="w-5 h-5 mr-1" />
          {gettext("You have redeemed this item!")}
        </p>
      </div>
    </li>
    """
  end
end
