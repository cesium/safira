defmodule SafiraWeb.App.StoreLive.Components.PurchaseModal do
  @moduledoc """
  Store purchase modal component that shows the user bought a product
  """

  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :wrapper_class, :string, default: ""
  attr :container_class, :string, default: "flex min-h-full items-center justify-center"
  attr :on_cancel, JS, default: %JS{}
  attr :purchase, :map, required: true
  attr :tokens, :integer, required: true

  attr :body_class, :string,
    default:
      "bg-primary w-full max-w-lg mx-auto rounded-2xl border border-light/10 ring-white p-8 pt-9"

  def purchase_modal(assigns) do
    ~H"""
    <.modal
      id={@id}
      show={@show}
      on_cancel={@on_cancel}
      wrapper_class={@wrapper_class}
      container_class={@container_class}
      body_class={@body_class}
    >
      <div class="flex flex-col items-center gap-6">
        <.icon name="fa-bag-shopping-solid" class="size-12" />
        <span class="text-center space-y-2">
          <h2 class="uppercase text-xl font-bold">{gettext("Purchase confirmed")}</h2>
          <p class="text-sm text-light/50">{gettext("Product added to your vault")}</p>
        </span>

        <div class="flex flex-col items-center gap-4 mt-2 w-full bg-dark-muted/10 p-4 rounded-xl border border-light/5">
          <p class="font-bold text-lg">{@purchase.name}</p>

          <div class="flex items-center justify-center gap-2 w-full rounded-xl border border-accent/40 bg-accent/5 p-4">
            <.icon name="fa-sack-dollar-solid" class="size-4" />
            <p class="text-xl md:text-2xl font-black">{@purchase.price}</p>
            <p class="text-sm text-light/50 -mb-1 md:-mb-2">tokens</p>
          </div>

          <div class="inline-flex w-full mt-4 items-center text-light/50 justify-between gap-2">
            <p>{gettext("New balance:")}</p>
            <p class="text-light font-medium">{@tokens} tokens</p>
          </div>
        </div>

        <.link
          navigate="/app/vault"
          class="text-light/50 gap-1 inline-flex items-center hover:text-light group transition-colors duration-300"
        >
          <p>{gettext("view vault")}</p>
          <.icon
            name="fa-chevron-right-solid"
            class="size-3 group-hover:translate-x-1 transition-transform duration-300"
          />
        </.link>
      </div>
    </.modal>
    """
  end
end
