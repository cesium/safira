defmodule SafiraWeb.Landing.ChallengesLive.Index do
  @moduledoc false

  use SafiraWeb, :landing_view

  alias Safira.Minigames
  alias SafiraWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    challenges = Minigames.list_challenges()

    {:noreply,
     socket
     |> assign(:challenges, challenges)
     |> assign(:selected_challenge, Enum.at(challenges, 0))}
  end

  @impl true
  def handle_event("challenge_change", %{"challenge_id" => challenge_id} = params, socket) do
    {:noreply,
     socket
     |> assign(
       :selected_challenge,
       Enum.find(socket.assigns.challenges, fn c -> c.id == challenge_id end)
     )}
  end
end
