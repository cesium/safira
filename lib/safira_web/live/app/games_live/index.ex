defmodule SafiraWeb.App.GamesLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.App.GamesLive.Components.GameCard

  @impl true
  def mount(_params, _session, socket) do
    games = [
      %{
        name: "Lucky Wheel",
        icon: "wheel.svg",
        path: "wheel",
        desc: "Spin the wheel and win exciting prizes"
      },
      %{
        name: "Slots",
        icon: "slots.svg",
        path: "slots",
        desc: "Test your luck with classic slot machines"
      },
      %{
        name: "Coin Flip",
        icon: "coin-flip.svg",
        path: "coin_flip",
        desc: "Heads or tails? Make your choice against other users"
      },
      %{
        name: "Scratch Card",
        # Fix: change icon
        icon: "wheel.svg",
        path: "scratch_card",
        desc: "Scratch scratch scratch, and reveal your fortune"
      }
    ]

    {:ok,
     socket
     |> assign(current_page: :games)
     |> assign(games: games)}
  end
end
