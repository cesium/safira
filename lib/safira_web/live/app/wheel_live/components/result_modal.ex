defmodule SafiraWeb.App.WheelLive.Components.ResultModal do
  @moduledoc """
  Lucky wheel drop result modal component.
  """
  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :drop_type, :atom, required: true
  attr :drop, :map, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :wrapper_class, :string, default: ""

  attr :content_class, :string,
    default:
      "bg-primary w-full max-w-lg mx-auto rounded-2xl border border-light/10 ring-white p-8 pt-9"

  attr :container_class, :string, default: "flex min-h-full items-center justify-center"
  attr :show_vault_link, :boolean, default: true

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
      data-is_win={@drop_type != nil}
    >
      <div class="flex flex-col items-center gap-6">
        <span class="text-center space-y-2">
          <h2 class="uppercase text-3xl font-bold">{result_title(@drop_type)}</h2>
          <p class="text-lg text-light/50">{result_description(@drop_type, @drop)}</p>
        </span>

        <div
          :if={result_reward?(@drop_type)}
          class="flex flex-col items-center gap-2 mt-2 w-full bg-dark-muted/10 p-4 rounded-xl border border-light/5"
        >
          <figure
            :if={@drop_type in [:prize, :badge]}
            class="w-full flex items-center justify-center"
          >
            <img
              :if={@drop_type == :prize}
              src={Uploaders.Prize.url({@drop.prize.image, @drop.prize}, :original, signed: true)}
              class="max-h-40"
            />
            <img
              :if={@drop_type == :badge}
              src={Uploaders.Badge.url({@drop.badge.image, @drop.badge}, :original, signed: true)}
              class="max-h-40"
            />
          </figure>

          <p
            :if={@drop_type in [:prize, :badge]}
            class="font-bold text-lg text-center"
          >
            {result_reward_label(@drop_type, @drop)}
          </p>

          <div
            :if={@drop_type in [:tokens, :entries]}
            class="flex flex-col items-center justify-center py-2"
          >
            <p class="text-3xl md:text-4xl font-black leading-none">
              {result_reward_amount(@drop_type, @drop)}
            </p>
            <p class="text-sm text-light/50 uppercase tracking-wide mt-1">
              {result_reward_unit(@drop_type, @drop)}
            </p>
          </div>
        </div>

        <.link
          :if={@drop_type == :prize and @show_vault_link}
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

  defp result_reward?(drop_type), do: drop_type in [:prize, :badge, :tokens, :entries]

  defp result_title(drop_type) when drop_type in [:prize, :badge, :tokens, :entries],
    do: gettext("Congratulations!")

  defp result_title(_drop_type), do: gettext("Oops... 👀")

  defp result_description(drop_type, _drop) do
    case drop_type do
      :prize ->
        gettext("You won the prize:")

      :badge ->
        gettext("You won the badge:")

      :tokens ->
        gettext("Token shower!")

      :entries ->
        gettext("Entry shower!")

      _ ->
        gettext("You didn't win anything this time. Maybe try again?")
    end
  end

  defp result_reward_label(:prize, drop), do: drop.prize.name
  defp result_reward_label(:badge, drop), do: drop.badge.name
  defp result_reward_label(_drop_type, _drop), do: ""

  defp result_reward_amount(:tokens, drop), do: drop.tokens
  defp result_reward_amount(:entries, drop), do: drop.entries
  defp result_reward_amount(_drop_type, _drop), do: nil

  defp result_reward_unit(:tokens, drop) when drop.tokens == 1, do: gettext("token")
  defp result_reward_unit(:tokens, _drop), do: gettext("tokens")

  defp result_reward_unit(:entries, drop) when drop.entries == 1, do: gettext("entry")
  defp result_reward_unit(:entries, _drop), do: gettext("entries")

  defp result_reward_unit(_drop_type, _drop), do: ""
end
