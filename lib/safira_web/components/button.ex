defmodule SafiraWeb.Components.Button do
  @moduledoc """
  Button component.
  """
  use SafiraWeb, :component

  import SafiraWeb.CoreComponents

  attr :title, :string, default: ""
  attr :subtitle, :string, default: ""
  attr :subtitle_icon, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :icon, :string, default: ""
  attr :class, :string, default: ""
  attr :title_class, :string, default: ""
  attr :subtitle_class, :string, default: ""

  attr :rest, :global,
    include:
      ~w(csrf_token download form href hreflang method name navigate patch referrerpolicy rel replace target type value autofocus tabindex),
    doc: "Arbitrary HTML or phx attributes."

  def action_button(assigns) do
    ~H"""
    <button
      class={"m-auto flex flex-col items-center justify-center gap-2 select-none cursor-pointer uppercase transition-all duration-300 ease-in-out text-2xl font-semibold disabled:hover:border-light/80 disabled:hover:bg-transparent disabled:hover:text-white disabled:hover:shadow-none disabled:cursor-not-allowed disabled:bg-light/20 disabled:opacity-75 h-20 w-full border-2 border-light/80 text-white hover:shadow-[0_0_20px_1px] shadow-accent/50 hover:border-transparent hover:bg-accent hover:text-primary rounded-2xl #{@class}"}
      disabled={@disabled}
      {@rest}
    >
      <%= if @icon != "" do %>
        <.icon name={@icon} />
      <% end %>
      <p class={"uppercase text-2xl font-semibold #{@title_class}"}>{@title}</p>
      <div
        :if={@subtitle != "" || @subtitle_icon != ""}
        class={["inline-flex items-center justify-center", @subtitle_icon != "" && "gap-2"]}
      >
        <.icon :if={@subtitle_icon != ""} name={"fa-" <> @subtitle_icon} class="size-3" />
        <p class={"text-base font-light #{@subtitle_class}"}>{@subtitle}</p>
      </div>
    </button>
    """
  end
end
