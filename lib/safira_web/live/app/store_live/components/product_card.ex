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
      class={"w-full flex flex-col items-center group overflow-hidden border-white/10 border-2 rounded-xl hover:-translate-y-1 transition-all duration-300 #{if @data.stock == 0 do "opacity-50" end}"}
    >
      <figure class={["w-full aspect-square filter-none", product_gradient_class(@data.id)]}>
        <%= if @data.image do %>
          <img
            class={"w-full h-full p-4 drop-shadow-[0_0_20px_rgba(255,255,255,0.2)] object-contain#{if @data.stock > 0 do " group-hover:scale-105" end} transition-transform duration-300"}
            src={Uploaders.Product.url({@data.image, @data}, :original, signed: true)}
          />
        <% end %>
      </figure>
      <div class="flex flex-col items-center gap-3 p-3 justify-center w-full bg-light/5">
        <p class="font-semibold">
          {@data.name}
        </p>
        <p class="text-center py-1">
          <span class={"border-2 rounded-lg border-light shadow-accent/50 px-8 transition-all duration-300 ease-in-out py-2 font-semibold flex justify-center gap-2 items-center#{if @data.stock > 0 do " group-hover:shadow-[0_0_20px_1px] group-hover:border-accent group-hover:bg-accent group-hover:text-primary" end}"}>
            <%= if @data.stock != 0 do %>
              <.icon name="fa-sack-dollar-solid" class="w-3.5" />
              {@data.price}
            <% else %>
              <.icon name="fa-ban-solid" />
              {gettext("Out of stock")}
            <% end %>
          </span>
        </p>
      </div>
    </.link>
    """
  end
end
