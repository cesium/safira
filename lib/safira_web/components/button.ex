defmodule SafiraWeb.Components.Button do
  @moduledoc """
  Button component.
  """
  use SafiraWeb, :component

  attr :title, :string, default: ""
  attr :subtitle, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :class, :string, default: ""

  attr :rest, :global,
    include:
      ~w(csrf_token download form href hreflang method name navigate patch referrerpolicy rel replace target type value autofocus tabindex),
    doc: "Arbitrary HTML or phx attributes."

  def action_button(assigns) do
    ~H"""
    <button
      class={"bg-accent hover:bg-accent/90 text-white font-bold py-2 px-4 rounded-full transition-colors disabled:cursor-not-allowed disabled:bg-zinc-500 #{@class}"}
      disabled={@disabled}
      {@rest}
    >
      <p class="uppercase font-terminal text-2xl"><%= @title %></p>
      <p class="font-terminal"><%= @subtitle %></p>
    </button>
    """
  end
end
