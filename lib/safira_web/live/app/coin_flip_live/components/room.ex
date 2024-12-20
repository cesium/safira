defmodule SafiraWeb.App.CoinFlipLive.Components.Room do
  @moduledoc """
  Coin Flip room component.
  """
  use SafiraWeb, :component

  import SafiraWeb.CoreComponents

  attr :room, :map, required: true
  attr :current_user, :map, required: true
  attr :id, :string, required: true

  def room(assigns) do
    ~H"""
    <div
      id={@id}
      class="flex flex-row items-center justify-center border border-darkMuted/70 rounded-md overflow-hidden"
    >
      <div class="relative flex flex-col items-center space-y-1 justify-between size-44">
        <%!-- <span class="rounded-full bg-white size-16"></span> --%>
        <img
          src={"https://github.com/identicons/#{@room.player1.user.handle |> String.slice(0..2)}.png"}
          class="size-full"
        />
        <span class="absolute bottom-0 bg-gradient-to-t from-primaryDark to-transparent size-full text-center flex flex-col justify-end pb-2">
          <.button
            class=" absolute size-2 top-0 -left-2 z-50"
            phx-click="delete-room"
            phx-value-room_id={@room.id}
          >
            a
          </.button>
          <%= @room.player1.user.handle %>
        </span>
        <div class="absolute coin size-12 top-1 left-2">
          <div class="side-a"></div>
        </div>
      </div>
      <div class="relative flex flex-col items-center justify-center h-full z-20">
        <div
          id={@id <> "-container"}
          class="absolute flex flex-col gap-1 items-center"
          phx-hook="CoinFlip"
          data-stream-id={@id}
          data-room-id={@room.id}
          data-result={@room.result}
          data-finished={to_string(@room.finished)}
        >
          <div id={@id <> "-coin"} class="coin">
            <div class="side-a"></div>
            <div class="side-b"></div>
          </div>
          <h1
            id={@id <> "-countdown"}
            class="text-2xl p-2 rounded-full bg-primaryDark/60 size-16 justify-center flex items-center"
          >
            3
          </h1>
          <span class="text-nowrap bg-primaryDark/60 py-1 px-2 rounded-md">
            💰 <%= @room.bet %>
          </span>
        </div>
      </div>
      <div class="relative flex flex-col items-center space-y-1 justify-between size-44">
        <%= if @room.player2_id do %>
          <img
            src={"https://github.com/identicons/#{@room.player2.user.handle |> String.slice(0..2)}.png"}
            class="size-full"
          />
          <span class="absolute bottom-0 bg-gradient-to-t from-primaryDark to-transparent size-full text-center flex flex-col justify-end pb-2">
            <%= @room.player2.user.handle %>
          </span>
          <div class="absolute coin size-12 top-1 right-2">
            <div class="side-b-not-rotated"></div>
          </div>
        <% else %>
          <.button
            :if={@room.player1.user.id != @current_user.id}
            class="px-7 size-full !bg-primaryDark !text-white hover:!bg-primary-950 rounded-none"
            phx-click="join-room"
            phx-value-room_id={@room.id}
          >
            <.icon name="hero-plus" class="size-12" />
          </.button>
          <.button
            :if={@room.player1.user.id == @current_user.id}
            class="px-7 my-auto size-full !bg-primaryDark !text-white hover:!bg-primary-950 rounded-none"
            phx-click="delete-room"
            phx-value-room_id={@room.id}
          >
            <.icon name="hero-x-mark" class="size-12" />
          </.button>
        <% end %>
      </div>
    </div>
    """
  end
end
