defmodule SafiraWeb.BadgeLive.Index do
  alias Safira.Contest.Badge
  use SafiraWeb, :backoffice_view

  alias Safira.Contest
  alias Safira.Contest.BadgeCategory

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:current_page, :badges)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Badge")
    |> assign(:badge, Contest.get_badge!(id))
    |> assign(:categories, Contest.list_badge_categories())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Badge")
    |> assign(:badge, %Badge{})
    |> assign(:categories, Contest.list_badge_categories())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Badges")
    |> stream(:badges, Contest.list_badges())
  end

  defp apply_action(socket, :categories_edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Contest.get_badge_category!(id))
  end

  defp apply_action(socket, :categories_new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %BadgeCategory{})
  end

  defp apply_action(socket, :categories, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
  end
end
