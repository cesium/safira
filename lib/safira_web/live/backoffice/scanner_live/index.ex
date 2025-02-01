defmodule SafiraWeb.Backoffice.ScannerLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Contest

  import SafiraWeb.Components.TableSearch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    badges =
      if user_can_bypass_badge_restrictions?(socket) do
        Contest.list_badges(params)
      else
        Contest.list_available_badges(params)
      end

    case badges do
      {:ok, {badges, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :scanner)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:badges, badges, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Badges")
  end

  defp user_can_bypass_badge_restrictions?(socket) do
    permissions = socket.assigns.current_user.staff.role.permissions

    Map.has_key?(permissions, "badges") and
      Map.get(permissions, "badges") |> Enum.member?("give_without_restrictions")
  end
end
