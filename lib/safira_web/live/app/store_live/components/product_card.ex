defmodule SafiraWeb.App.StoreLive.Components.ProductCard do
  @moduledoc """
  Product card component.
  """
  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :data, :map, required: true

  def product_card(assigns) do
    ~H"""
    <.link
      id={@id}
      patch={~p"/app/store/product/#{@data.id}"}
      class={"w-full flex flex-col items-center sm:w-min group #{if @data.stock == 0 do "opacity-50" end}"}
    >
      <figure class="bg-light/5 rounded-xl w-80 h-80">
        <%= if @data.image do %>
          <img
            class={"w-full p-4 #{if @data.stock > 0 do "group-hover:scale-105" end} transition-transform duration-300"}
            src={Uploaders.Product.url({@data.image, @data}, :original, signed: true)}
          />
        <% end %>
      </figure>
      <p class="text-center py-3 font-semibold">
        <%= @data.name %>
      </p>
      <p class="text-center py-1">
        <span class="rounded-full border-2 border-light px-4 py-2 font-semibold font-terminal uppercase">
          <%= if @data.stock != 0 do %>
            💰 <%= @data.price %>
          <% else %>
            🚫 <%= gettext("Out of stock") %>
          <% end %>
        </span>
      </p>
    </.link>
    """
  end
end
