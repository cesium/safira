defmodule SafiraWeb.App.GamesLive.SlotsLive.Components.ResultModal do
  @moduledoc """
  Slots result modal component.
  """
  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :multiplier, :integer, required: true
  attr :winnings, :integer, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}

  attr :wrapper_class, :string, default: ""

  attr :content_class, :string,
    default:
      "bg-primary w-full max-w-lg mx-auto rounded-2xl border border-light/10 ring-white p-8 pt-9"

  attr :container_class, :string, default: "flex min-h-full items-center justify-center"

  def result_modal(assigns) do
    ~H"""
    <.modal
      id={@id}
      show={@show}
      on_cancel={@on_cancel}
      wrapper_class={@wrapper_class}
      body_class={@content_class}
      container_class={@container_class}
      phx-hook="Confetti"
      data-is_win={win_result?(@multiplier)}
    >
      <div class="flex flex-col items-center gap-6">
        <span class="text-center space-y-2">
          <h2 class="uppercase text-3xl font-bold">{result_title(@multiplier)}</h2>
          <p class="text-lg text-light/50">{result_description(@multiplier, @winnings)}</p>
        </span>

        <div class="flex flex-col items-center gap-3 mt-2 w-full bg-dark-muted/10 p-4 rounded-xl border border-light/5">
          <p class="uppercase text-xs tracking-wide text-light/50">{gettext("Result")}</p>
          <p class="font-bold text-2xl text-center text-light">
            {gettext("%{winnings} tokens", winnings: @winnings)}
          </p>

          <p class="text-sm text-light/50 text-center">
            {multiplier_text(@multiplier)}
          </p>
        </div>
      </div>
    </.modal>
    """
  end

  defp win_result?(multiplier), do: multiplier > 1

  defp result_title(multiplier) do
    cond do
      multiplier == 1 -> gettext("Bet refunded")
      multiplier > 1 -> gettext("Congratulations!")
    end
  end

  defp result_description(multiplier, winnings) do
    cond do
      multiplier == 1 ->
        gettext("You got back %{winnings} tokens. Want to try again?", winnings: winnings)

      multiplier > 1 ->
        gettext("You hit a winning combination.")
    end
  end

  defp multiplier_text(multiplier) do
    gettext("Multiplier: x%{multiplier}", multiplier: multiplier)
  end
end
