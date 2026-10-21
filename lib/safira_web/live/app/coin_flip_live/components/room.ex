defmodule SafiraWeb.App.CoinFlipLive.Components.Room do
  @moduledoc """
  Coin Flip room component.
  """
  use SafiraWeb, :component

  import SafiraWeb.CoreComponents
  import SafiraWeb.Components.Avatar

  attr :room, :map, required: true
  attr :current_user, :map, required: true
  attr :attendee_tokens, :integer, required: true
  attr :id, :string, required: true
  attr :coin_flip_fee, :float, required: true

  def room(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="CoinFlip"
      data-stream-id={@id}
      data-room-id={@room.id}
      data-result={@room.result}
      data-finished={to_string(@room.finished)}
      data-player1-id={@room.player1_id}
      data-player2-id={@room.player2_id}
      data-fee={@coin_flip_fee}
      class={[
        "relative grid grid-cols-3 items-center gap-2 sm:gap-4 bg-light/5 w-full rounded-md p-3 sm:p-4",
        @current_user.attendee.id in [@room.player1_id, @room.player2_id] && not @room.finished &&
          "border-2 border-accent/50 shadow-[0px_0px_20px_2px] shadow-accent/40",
        (@current_user.attendee.id not in [@room.player1_id, @room.player2_id] || @room.finished) &&
          "border border-light/10"
      ]}
    >
      <div class="min-w-0 flex justify-center">
        <.player_card
          stream_id={@id}
          player_id={@room.player1_id}
          player={@room.player1}
          current_user={@current_user}
          attendee_tokens={@attendee_tokens}
          room={@room}
        />
      </div>

      <div class="relative z-20 pointer-events-none min-w-14 sm:min-w-20 flex items-center justify-center h-full">
        <h1 id={@id <> "-vs-text"} class="font-bold align-middle">VS</h1>
        <div class="absolute inset-0 flex items-center justify-center">
          <div id={@id <> "-coin"} class="coin-main hidden">
            <div class="side-a"></div>
            <div class="side-b"></div>
          </div>
        </div>
        <h1
          id={@id <> "-countdown"}
          class="absolute text-2xl p-2 rounded-full bg-accent/25 font-bold size-16 justify-center hidden items-center"
        >
          3
        </h1>
      </div>

      <div class="min-w-0 flex justify-center">
        <.player_card
          stream_id={@id}
          player_id={@room.player2_id}
          player={@room.player2}
          current_user={@current_user}
          attendee_tokens={@attendee_tokens}
          room={@room}
        />
      </div>
    </div>
    """
  end

  attr :stream_id, :string, required: true
  attr :player_id, :string, required: true
  attr :player, :map, required: true
  attr :current_user, :map, required: true
  attr :attendee_tokens, :integer, required: true
  attr :room, :map, required: true

  defp player_card(assigns) do
    ~H"""
    <div
      id={"#{@stream_id}-#{@player_id}-card"}
      class="flex flex-col gap-2 items-center relative justify-center h-full select-none min-w-0 w-full max-w-34 sm:max-w-40"
    >
      <%= if @player_id do %>
        <div class="relative inline-flex">
          <.avatar
            handle={@player.user.handle}
            src={
              Uploaders.UserPicture.url({@player.user.picture, @player.user}, :original, signed: true)
            }
            size={:md}
            class="shadow-[0_0_20px_2px] shadow-light/25 rounded-full"
          />

          <div class="absolute coin-mini size-7 sm:size-8 -top-1 -right-1 sm:-top-1.5 sm:-right-1.5">
            <div :if={@player_id == @room.player1_id} class="side-a"></div>
            <div :if={@player_id == @room.player2_id} class="side-b-not-rotated"></div>
          </div>
        </div>

        <span class="block w-full max-w-24 sm:max-w-32 mx-auto font-semibold text-light text-xs text-center truncate whitespace-nowrap">
          @{@player.user.handle}
        </span>

        <span class="inline-flex items-center gap-1">
          <.icon name="fa-sack-dollar-solid" class="size-3.5 text-accent" />
          <span
            id={"#{@stream_id}-#{@player_id}-bet"}
            class="text-sm font-semibold"
            data-bet={@room.bet}
          >
            {@room.bet}
          </span>
        </span>
      <% else %>
        <div class="border-2 flex items-center justify-center border-dashed border-light/20 size-18 rounded-full aspect-square">
          <.button
            :if={@room.player1.user.id != @current_user.id}
            class="size-full rounded-none bg-transparent! cursor-pointer text-white!"
            phx-click="join-room"
            phx-value-room_id={@room.id}
            disabled={@attendee_tokens < @room.bet}
          >
            <.icon name="fa-plus-solid" class="size-8 text-light/30 animate-pulse" />
          </.button>

          <.button
            :if={@room.player1.user.id == @current_user.id}
            class="size-full rounded-none bg-transparent! text-white!"
            phx-click="delete-room"
            phx-value-room_id={@room.id}
          >
            <.icon name="fa-xmark-solid" class="size-8 text-light/30 animate-pulse" />
          </.button>
        </div>

        <p class="text-light/20 text-sm font-medium animate-pulse">{gettext("Waiting...")}</p>
      <% end %>
    </div>
    """
  end
end
