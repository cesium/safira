defmodule SafiraWeb.Components.Button do
  @moduledoc """
  Button component.
  """
  use SafiraWeb, :component

  import SafiraWeb.CoreComponents

  attr :title, :string, default: ""
  attr :subtitle, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :icon, :string, default: ""
  attr :class, :string, default: ""
  attr :title_class, :string, default: ""

  attr :rest, :global,
    include:
      ~w(csrf_token download form href hreflang method name navigate patch referrerpolicy rel replace target type value autofocus tabindex),
    doc: "Arbitrary HTML or phx attributes."

  def action_button(assigns) do
    ~H"""
    <button
      class={"m-auto block select-none rounded-full hover:opacity-75 disabled:hover:border-white disabled:hover:text-white disabled:cursor-not-allowed disabled:bg-gray-400 disabled:opacity-75 h-20 w-full border-2 border-white text-white transition-colors hover:border-accent hover:bg-accent/10 hover:text-accent #{@class}"}
      disabled={@disabled}
      {@rest}
    >
      <%= if @icon != "" do %>
        <.icon name={@icon} />
      <% end %>
      <p class={"uppercase font-terminal text-2xl #{@title_class}"}>{@title}</p>
      <p class="font-terminal">{@subtitle}</p>
    </button>
    """
  end
end
