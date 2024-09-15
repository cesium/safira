defmodule SafiraWeb.Components.Page do
  use Phoenix.Component

  import SafiraWeb.CoreComponents

  attr :title, :string, required: true
  attr :subtitle, :string, default: ""
  attr :style, :atom, values: [:app, :backoffice], default: :app
  attr :size, :atom, values: [:sm, :md, :xl], default: :md

  slot :actions, optional: true, doc: "Slot for actions to be rendered in the page header."
  slot :inner_block, required: true, doc: "Slot for the body content of the page."

  def page(assigns) do
    ~H"""
    <div>
      <.header title_class={size_class(@size)}>
        <%= @title %>
        <:subtitle>
          <%= @subtitle %>
        </:subtitle>
        <:actions>
          <%= render_slot(@actions) %>
        </:actions>
      </.header>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def size_class(size) do
    %{
      sm: "text-md",
      md: "text-lg",
      xl: "text-2xl"
    }[size]
  end
end
