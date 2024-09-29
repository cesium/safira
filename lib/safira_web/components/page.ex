defmodule SafiraWeb.Components.Page do
  @moduledoc """
  Page layout component.
  """
  use Phoenix.Component

  import SafiraWeb.CoreComponents

  attr :title, :string, default: ""
  attr :subtitle, :string, default: ""
  attr :style, :atom, values: [:app, :backoffice], default: :app
  attr :size, :atom, values: [:sm, :md, :xl], default: :md
  attr :title_class, :string, default: ""
  attr :back_to_link, :string, default: nil
  attr :back_to_link_text, :string, default: "Back"

  slot :actions, optional: true, doc: "Slot for actions to be rendered in the page header."
  slot :inner_block, required: true, doc: "Slot for the body content of the page."

  def page(assigns) do
    ~H"""
    <div>
      <.header title_class={"#{size_class(@size)} #{@title_class}"}>
        <%= @title %>
        <:subtitle>
          <%= @subtitle %>
        </:subtitle>
        <%= if @back_to_link do %>
          <.link patch={@back_to_link}>
            <.icon name="hero-arrow-left" />
            <%= @back_to_link_text %>
          </.link>
        <% end %>
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
      xl: "text-3xl"
    }[size]
  end
end
