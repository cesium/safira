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
        "relative flex flex-row items-center justify-between bg-primary rounded-md w-full max-w-96 h-52 p-3 sm:p-4",
        @current_user.attendee.id in [@room.player1_id, @room.player2_id] && not @room.finished &&
          "ring-1 ring-accent shadow-[0px_0px_16px_1px]
    shadow-accent",
        (@current_user.attendee.id not in [@room.player1_id, @room.player2_id] || @room.finished) &&
          "ring-1 ring-darkShade"
      ]}
    >
      <.player_card
        stream_id={@id}
        player_id={@room.player1_id}
        player={@room.player1}
        current_user={@current_user}
        attendee_tokens={@attendee_tokens}
        room={@room}
      />
      <div class="absolute inset-0 flex flex-col items-center justify-center h-full z-20 pointer-events-none">
        <h1 id={@id <> "-vs-text"} class="font-terminal font-bold align-middle">VS</h1>
        <div id={@id <> "-coin"} class="coin hidden">
          <div class="side-a"></div>
          <div class="side-b"></div>
        </div>
        <h1
          id={@id <> "-countdown"}
          class="absolute text-2xl p-2 rounded-full bg-blue-900/25 font-terminal font-bold size-16 justify-center hidden items-center"
        >
          3
        </h1>
      </div>
      <.player_card
        stream_id={@id}
        player_id={@room.player2_id}
        player={@room.player2}
        current_user={@current_user}
        attendee_tokens={@attendee_tokens}
        room={@room}
      />
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
      class="relative flex flex-col flex-shrink-0 items-center space-y-1 border border-darkShade/80 bg-blue-900/25 rounded-md h-full w-32 p-1 select-none"
    >
      <%= if @player_id do %>
        <div class="h-full flex items-center">
          <.avatar
            handle={@player.user.handle}
            src={
              Uploaders.UserPicture.url({@player.user.picture, @player.user}, :original, signed: true)
            }
            size={:lg}
          />
        </div>
        <span class="text-center flex flex-col truncate pb-3 text-xs">
          <%= @player.user.handle %>
        </span>
        <span class="text-nowrap bg-primary/60 py-1 px-2 rounded-md align-middle">
          <.icon name="hero-currency-dollar-solid" class="text-yellow-300" />
          <span id={"#{@stream_id}-#{@player_id}-bet"} class="font-terminal" data-bet={@room.bet}>
            <%= @room.bet %>
          </span>
        </span>
        <div class="absolute coin size-10 top-1 right-2">
          <div :if={@player_id == @room.player1_id} class="side-a"></div>
          <div :if={@player_id == @room.player2_id} class="side-b-not-rotated"></div>
        </div>
      <% else %>
        <.button
          :if={@room.player1.user.id != @current_user.id}
          class="px-7 size-full rounded-none !bg-transparent !text-white"
          phx-click="join-room"
          phx-value-room_id={@room.id}
          disabled={@attendee_tokens < @room.bet}
        >
          <.icon name="hero-plus" class="size-12" />
        </.button>
        <.button
          :if={@room.player1.user.id == @current_user.id}
          class="px-7 my-auto size-full rounded-none !bg-transparent !text-white"
          phx-click="delete-room"
          phx-value-room_id={@room.id}
        >
          <.icon name="hero-x-mark" class="size-12" />
        </.button>
      <% end %>
    </div>
    """
  end
end
