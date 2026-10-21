defmodule SafiraWeb.App.GamesLive.ScratchCardLive.Components.PaytableModal do
  @moduledoc """
  ScratchCard paytable modal component that shows winning patterns
  """

  use SafiraWeb, :component

  alias Safira.Minigames
  alias Safira.Uploaders.ScratchCardSymbols

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :wrapper_class, :string, default: ""
  attr :on_cancel, JS, default: %JS{}

  attr :body_class, :string,
    default: "bg-primary w-full rounded-2xl border border-light/10 ring-white p-8 pt-9"

  def paytable_modal(assigns) do
    drops = Minigames.list_scratch_card_drops()

    assigns = assign(assigns, drops: drops)

    ~H"""
    <.modal
      id={@id}
      show={@show}
      on_cancel={@on_cancel}
      wrapper_class={@wrapper_class}
      body_class={@body_class}
    >
      <h2 class="text-3xl font-bold text-center mb-4 md:mb-8">
        {gettext("PAYTABLE")}
      </h2>

      <div class="space-y-6" id="paytable-content" phx-hook="PaytableModal">
        <%= for drop <- @drops do %>
          <div class="flex items-center justify-between border-b border-light/5 pb-4 last:border-0">
            <div class="flex flex-col gap-1">
              <h3 class="text-xl font-semibold uppercase">
                {get_prize_name(drop)}
              </h3>
              <p class="text-sm text-light/50">
                {gettext("Probability: %{probability}%",
                  probability: Float.round(drop.probability * 100, 4)
                )}
              </p>
            </div>

            <div class="flex items-center justify-between">
              <img
                :for={_i <- 1..3}
                src={
                  ScratchCardSymbols.url(
                    {drop.scratch_card_symbol.image, drop.scratch_card_symbol},
                    :original,
                    signed: true
                  )
                }
                class="w-full h-full object-cover"
                alt="Slot icon"
              />
            </div>
          </div>
        <% end %>
      </div>
    </.modal>
    """
  end

  defp get_prize_name(drop) do
    case Minigames.get_drop_type(drop) do
      :tokens -> "#{drop.tokens} Tokens"
      :badge -> "'#{drop.badge.name}' Badge"
      :entries -> "#{drop.entries} Entries"
      :prize -> drop.prize.name
      _ -> "Scratchcard Prize"
    end
  end
end
