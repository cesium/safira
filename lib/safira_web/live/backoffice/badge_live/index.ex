defmodule SafiraWeb.BadgeLive.Index do
  alias Safira.Contest.BadgeCondition
  alias Safira.Contest.Badge
  use SafiraWeb, :backoffice_view

  import SafiraWeb.Components.TableSearch

  alias Safira.Contest
  alias Safira.Contest.BadgeCategory

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Contest.list_badges(params) do
      {:ok, {badges, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :badges)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:badges, badges, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
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

  defp apply_action(socket, :conditions_edit, %{"id" => badge_id, "condition_id" => condition_id}) do
    socket
    |> assign(:page_title, "Edit Condition")
    |> assign(:badge, Contest.get_badge!(badge_id))
    |> assign(:badge_condition, Contest.get_badge_condition!(condition_id))
  end

  defp apply_action(socket, :conditions_new, %{"id" => id}) do
    socket
    |> assign(:page_title, "New Condition")
    |> assign(:badge, Contest.get_badge!(id))
    |> assign(:badge_condition, %BadgeCondition{})
  end

  defp apply_action(socket, :conditions, %{"id" => id}) do
    badge = Contest.get_badge!(id)

    socket
    |> assign(:page_title, "Listing #{badge.name} Conditions")
    |> assign(:badge, badge)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    badge = Contest.get_badge!(id)
    {:ok, _} = Contest.delete_badge(badge)

    {:noreply, stream_delete(socket, :badges, badge)}
  end
end
