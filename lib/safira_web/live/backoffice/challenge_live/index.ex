defmodule SafiraWeb.Backoffice.ChallengeLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Challenges
  alias Safira.Challenges.Challenge

  alias Safira.Minigames

  alias SafiraWeb.Helpers

  import SafiraWeb.Components.Table
  import SafiraWeb.Components.TableSearch

  on_mount {SafiraWeb.StaffRoles,
            index: %{"challenges" => ["show"]},
            new: %{"challenges" => ["edit"]},
            edit: %{"challenges" => ["edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Challenges.list_challenges(params) do
      {:ok, {challenges, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :challenges)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:prizes, Minigames.list_prizes())
         |> stream(:challenges, challenges, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Challenge")
    |> assign(:challenge, Challenges.get_challenge!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Challenge")
    |> assign(:challenge, %Challenge{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Challenges")
    |> assign(:challenge, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    challenge = Challenges.get_challenge!(id)
    {:ok, _} = Challenges.delete_challenge(challenge)

    {:noreply, stream_delete(socket, :challenges, challenge)}
  end
end
