defmodule SafiraWeb.App.SlotsLive.Components.PaytableModal do
  @moduledoc """
  Slots paytable modal component that shows winning combinations
  """
  use SafiraWeb, :component

  alias Safira.Minigames
  alias Safira.Uploaders.SlotsReelIcon

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :wrapper_class, :string, default: ""
  attr :on_cancel, JS, default: %JS{}

  def paytable_modal(assigns) do
    paylines = Minigames.list_slots_paylines()
    reel_icons = Minigames.list_slots_reel_icons()

    reel_0_icons = sort_reel_icons(reel_icons, :reel_0_index)
    reel_1_icons = sort_reel_icons(reel_icons, :reel_1_index)
    reel_2_icons = sort_reel_icons(reel_icons, :reel_2_index)

    reel_icons_map = %{
      0 => index_icons_by_position(reel_0_icons, :reel_0_index),
      1 => index_icons_by_position(reel_1_icons, :reel_1_index),
      2 => index_icons_by_position(reel_2_icons, :reel_2_index)
    }

    assigns =
      assign(assigns,
        paylines_by_multiplier: group_paylines_by_multiplier(paylines),
        reel_icons_map: reel_icons_map
      )

    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
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
          <div class="w-full max-w-lg">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="bg-primary shadow-zinc-700/10 relative hidden ring-4 ring-white rounded-2xl py-8 px-5 max-h-[500px] overflow-y-scroll scrollbar-hide shadow-lg transition"
            >
              <h2 class="text-3xl font-terminal font-bold text-center mb-6">
                <%= gettext("PAYTABLE") %>
              </h2>

              <div class="space-y-6" id="paytable-content" phx-hook="PaytableModal">
                <%= for {paytable, paylines_filtered} <- @paylines_by_multiplier do %>
                  <div class="flex justify-between border-b border-white/20 pb-4 last:border-0">
                    <div class="flex flex-col gap-1">
                      <h3 class="text-xl font-terminal font-semibold uppercase">
                        <%= if paytable.multiplier == 1,
                          do: "Refund",
                          else: "#{paytable.multiplier}x Multiplier" %>
                      </h3>
                      <p class="mb-3 text-sm text-slate-300">
                        <%= gettext("Probability: %{probability}%",
                          probability: Float.round(paytable.probability * 100, 4)
                        ) %>
                      </p>
                    </div>

                    <div class="payline-group">
                      <%= for {payline, idx} <- Enum.with_index(paylines_filtered) do %>
                        <div class={"flex items-center justify-center gap-2 payline-item #{if idx != 0, do: "hidden", else: ""}"}>
                          <%= for {position, reel_idx} <- Enum.with_index([payline.position_0, payline.position_1, payline.position_2]) do %>
                            <div class="size-14 sm:size-16 bg-primary rounded-lg overflow-hidden flex items-center justify-center">
                              <%= if is_nil(position) do %>
                                <span class="text-3xl font-terminal font-semibold">ANY</span>
                              <% else %>
                                <%= if icon = @reel_icons_map[reel_idx][position] do %>
                                  <img
                                    src={
                                      SlotsReelIcon.url({icon.image, icon}, :original, signed: true)
                                    }
                                    class="w-full h-full object-cover"
                                    alt="Slot icon"
                                  />
                                <% end %>
                              <% end %>
                            </div>
                          <% end %>
                        </div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp sort_reel_icons(icons, reel_field) do
    icons
    |> Enum.filter(&(Map.get(&1, reel_field) != -1))
    |> Enum.sort_by(&Map.get(&1, reel_field))
  end

  defp index_icons_by_position(icons, field) do
    Enum.reduce(icons, %{}, fn icon, acc ->
      Map.put(acc, Map.get(icon, field), icon)
    end)
  end

  defp group_paylines_by_multiplier(paylines) do
    paylines
    |> Enum.group_by(& &1.paytable_id)
    |> Enum.map(fn {paytable_id, paylines} ->
      paytable = Minigames.get_slots_paytable!(paytable_id)
      {paytable, paylines}
    end)
    |> Enum.sort_by(fn {paytable, _} -> paytable.multiplier end, :desc)
  end
end
