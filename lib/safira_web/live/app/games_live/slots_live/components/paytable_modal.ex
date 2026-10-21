defmodule SafiraWeb.App.GamesLive.SlotsLive.Components.PaytableModal do
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

  attr :body_class, :string,
    default: "bg-primary w-full rounded-2xl border border-light/10 ring-white p-8 pt-9"

  def paytable_modal(assigns) do
    paylines = Minigames.list_slots_paylines()
    reel_icons = Minigames.list_slots_reel_icons()

    reel_icons_map = %{
      0 => index_icons_by_position(sort_reel_icons(reel_icons, :reel_0_index), :reel_0_index),
      1 => index_icons_by_position(sort_reel_icons(reel_icons, :reel_1_index), :reel_1_index),
      2 => index_icons_by_position(sort_reel_icons(reel_icons, :reel_2_index), :reel_2_index)
    }

    assigns =
      assign(assigns,
        paylines_by_multiplier: group_paylines_by_multiplier(paylines),
        reel_icons_map: reel_icons_map
      )

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

      <div class="flex flex-col" id="paytable-content" phx-hook="PaytableModal">
        <%= for {paytable, paylines_filtered} <- @paylines_by_multiplier do %>
          <div class="flex flex-col md:flex-row justify-between items-center py-4 border-b-2 gap-4 border-light/5 last:border-0">
            <div class="flex flex-col gap-1 items-center md:items-start">
              <h3 class="text-lg md:text-xl font-semibold uppercase">
                {if paytable.multiplier == 1,
                  do: "Refund",
                  else: "#{paytable.multiplier}x Multiplier"}
              </h3>
              <p class="text-sm text-light/50 self-start">
                {gettext("Probability: %{probability}%",
                  probability: Float.round(paytable.probability * 100, 4)
                )}
              </p>
            </div>

            <div class="payline-group">
              <%= for {payline, idx} <- Enum.with_index(paylines_filtered) do %>
                <div class={"flex items-center justify-center gap-2 payline-item #{if idx != 0, do: "hidden", else: ""}"}>
                  <%= for {position, reel_idx} <- Enum.with_index([payline.position_0, payline.position_1, payline.position_2]) do %>
                    <div class="size-14 sm:size-16 rounded-lg overflow-hidden flex items-center justify-center">
                      <%= if is_nil(position) do %>
                        <span class="text-3xl font-semibold">ANY</span>
                      <% else %>
                        <%= if icon = @reel_icons_map[reel_idx][position] do %>
                          <img
                            src={SlotsReelIcon.url({icon.image, icon}, :original, signed: true)}
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
    </.modal>
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
