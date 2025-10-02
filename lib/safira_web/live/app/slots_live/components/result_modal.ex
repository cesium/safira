defmodule SafiraWeb.App.SlotsLive.Components.ResultModal do
  @moduledoc """
  Slots result modal component.
  """
  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :multiplier, :integer, required: true
  attr :winnings, :integer, required: true
  attr :show, :boolean, default: false
  attr :text, :string, default: ""
  attr :wrapper_class, :string, default: ""
  attr :on_cancel, JS, default: %JS{}
  attr :content_class, :string, default: "bg-primary"

  def result_modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Confetti"
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      data-is_win={@multiplier > 1}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-dark/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class={"fixed inset-0 overflow-y-auto #{@wrapper_class}"}
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-4xl">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class={"#{@content_class} shadow-zinc-700/10 relative hidden ring-4 ring-white rounded-2xl py-14 px-5 shadow-lg transition"}
            >
              <div
                id={"#{@id}-content"}
                class="font-terminal uppercase text-3xl md:text-4xl text-center"
              >
                {get_spin_result_title(@multiplier)}
              </div>
              <div class="text-center mt-4">
                {get_spin_result_text(@multiplier, @winnings)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_spin_result_title(multiplier) do
    cond do
      multiplier == 1 -> gettext("Bet refunded! 💰")
      multiplier > 1 -> gettext("You won tokens! 🎉")
    end
  end

  defp get_spin_result_text(multiplier, winnings) do
    cond do
      multiplier == 1 ->
        gettext("Phew, your bet was refunded! Will you try your luck with another spin?")

      multiplier > 1 ->
        gettext("Congratulations! You won %{winnings} tokens!", winnings: winnings)
    end
  end
end
