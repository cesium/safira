defmodule SafiraWeb.Backoffice.MinigamesLive.PrizeLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Minigames
  alias Safira.Minigames.Prize

  import SafiraWeb.Components.Table
  import SafiraWeb.Components.TableSearch

  on_mount {SafiraWeb.StaffRoles,
            index: %{"minigames" => ["show"]}, new: %{"minigames" => ["edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Minigames.list_prizes(params) do
      {:ok, {prizes, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :prizes)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:prizes, prizes, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Prize")
    |> assign(:prize, Minigames.get_prize!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Prize")
    |> assign(:prize, %Prize{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Prizes")
    |> assign(:prize, nil)
  end

  defp apply_action(socket, :daily, _params) do
    socket
    |> assign(:page_title, "Daily Prizes")
    |> assign(:prize, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    prize = Minigames.get_prize!(id)
    {:ok, _} = Minigames.delete_prize(prize)

    {:noreply, stream_delete(socket, :prizes, prize)}
  end
end
