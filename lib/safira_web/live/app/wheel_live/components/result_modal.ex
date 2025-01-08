defmodule SafiraWeb.App.WheelLive.Components.ResultModal do
  @moduledoc """
  Lucky wheel drop result modal component.
  """
  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :drop_type, :atom, required: true
  attr :drop, :map, required: true
  attr :show, :boolean, default: false
  attr :text, :string, default: ""
  attr :wrapper_class, :string, default: ""
  attr :on_cancel, JS, default: %JS{}
  attr :content_class, :string, default: "bg-primary"
  attr :show_vault_link, :boolean, default: true

  def result_modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Confetti"
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      data-is_win={@drop_type != nil}
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
              class={"#{@content_class} shadow-zinc-700/10 relative hidden ring-4 ring-white rounded-2xl p-14 shadow-lg transition"}
            >
              <div id={"#{@id}-content"} class="font-terminal uppercase text-3xl md:text-4xl">
                <p><%= get_drop_result_text(@drop_type, @drop) %></p>
              </div>
              <div
                :if={@drop_type in [:prize, :badge]}
                class="w-full py-4 px-8 sm:px-32 flex flex-row items-center justify-center"
              >
                <figure>
                  <img
                    :if={@drop_type == :prize}
                    src={
                      Uploaders.Prize.url({@drop.prize.image, @drop.prize}, :original, signed: true)
                    }
                    class="max-h-52"
                  />
                  <img
                    :if={@drop_type == :badge}
                    src={
                      Uploaders.Badge.url({@drop.badge.image, @drop.badge}, :original, signed: true)
                    }
                    class="min-h-52"
                  />
                </figure>
              </div>
              <%= if @drop_type == :prize and @show_vault_link do %>
                <p class="font-md text-center">
                  <%= gettext("You can redeem this prize at the accreditation by showing your") %>
                  <span>
                    <.link navigate={~p"/app/vault"} class="text-accent">
                      <%= gettext("vault") %>
                    </.link>
                  </span>
                </p>
              <% end %>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_drop_result_text(drop_type, drop) do
    case drop_type do
      :prize ->
        gettext("Congratulations! You won %{prize_name} ✨", prize_name: drop.prize.name)

      :badge ->
        gettext("Congratulations! You won the %{badge_name} badge!", badge_name: drop.badge.name)

      :tokens ->
        if drop.tokens == 1 do
          gettext("Congratulations! You won %{tokens} token 💰!", tokens: drop.tokens)
        else
          gettext("Congratulations! You won %{tokens} tokens 💰!", tokens: drop.tokens)
        end

      :entries ->
        if drop.entries == 1 do
          gettext("Congratulations! You won 🎫 %{entries} entry to the final draw!",
            entries: drop.entries
          )
        else
          gettext("Congratulations! You won 🎫 %{entries} entries to the final draw!",
            entries: drop.entries
          )
        end

      _ ->
        gettext("Oops.. You didn't win anything.. Maybe spin again? 👀")
    end
  end
end
