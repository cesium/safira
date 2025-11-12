defmodule SafiraWeb.Components.Tabs do
  @moduledoc false
  use SafiraWeb, :component

  attr :class, :string, default: "", doc: "The class to apply to the tabs"
  attr :underline, :boolean, default: true, doc: "Whether to show a bottom border on the tabs"
  attr :rest, :global
  slot :inner_block, required: false

  def tabs(assigns) do
    ~H"""
    <div
      {@rest}
      class={[
        "flex gap-x-8 gap-y-2",
        @underline && "border-b border-lightShade dark:border-darkShade",
        @class
      ]}
      aria-label="Tabs"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: "", doc: "The class to apply to the tab"
  attr :label, :string, default: nil, doc: "The label for the tab"
  attr :number, :integer, default: nil, doc: "Displays a number next to the tab label"
  attr :underline, :boolean, default: true, doc: "Whether to show a bottom border on the tab"
  attr :active, :boolean, default: false, doc: "Whether the tab is active"
  attr :disabled, :boolean, default: false, doc: "Whether the tab is disabled"
  attr :rest, :global
  slot :inner_block, required: false

  def tab(assigns) do
    ~H"""
    <button class={tab_class(@active, @underline) ++ [@class]} disabled={@disabled} {@rest}>
      <%= if @number do %>
        {render_slot(@inner_block) || @label}
        <span class={number_class(@active, @underline)}>
          {@number}
        </span>
      <% else %>
        {render_slot(@inner_block) || @label}
      <% end %>
    </button>
    """
  end

  defp tab_class(active, false) do
    base_classes =
      "flex items-center px-3 py-2 text-sm font-medium rounded-md whitespace-nowrap w-full justify-center"

    active_classes =
      if active,
        do: "text-dark dark:text-light dark:bg-light/5",
        else: "text-zinc-500 hover:text-zinc-600 dark:text-darkMuted"

    [base_classes, active_classes]
  end

  defp tab_class(active, underline) do
    base_classes =
      "flex items-center px-3 py-3 text-sm font-medium border-b-2 whitespace-nowrap w-full justify-center"

    active_classes =
      if active,
        do: "border-dark text-dark dark:text-light dark:border-light",
        else:
          "text-zinc-500 border-transparent hover:border-zinc-300 hover:text-zinc-600 dark:text-darkMuted"

    underline_classes =
      if active && underline,
        do: "",
        else: "hover:border-zinc-300"

    [base_classes, active_classes, underline_classes]
  end

  defp number_class(active, true) do
    base_classes = "whitespace-nowrap ml-2 py-0.5 px-2 rounded-full text-xs font-normal"

    active_classes =
      if active,
        do: "text-white bg-orange-600",
        else: "text-white bg-zinc-500"

    underline_classes =
      if active,
        do: "bg-orange-100 text-orange-600",
        else: "text-zinc-500 bg-zinc-100"

    [base_classes, active_classes, underline_classes]
  end

  defp number_class(active, false) do
    base_classes = "whitespace-nowrap ml-2 py-0.5 px-2 rounded-full text-xs font-normal"

    active_classes =
      if active,
        do: "text-white bg-primary-600",
        else: "text-white bg-zinc-500"

    [base_classes, active_classes]
  end
end
