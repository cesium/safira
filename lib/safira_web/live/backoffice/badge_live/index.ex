defmodule SafiraWeb.Backoffice.BadgeLive.Index do
  use SafiraWeb, :backoffice_view

  import SafiraWeb.Components.{Badge, Table, TableSearch}

  alias Safira.Contest
  alias Safira.Contest.{Badge, BadgeCategory, BadgeCondition, BadgeTrigger}

  on_mount {SafiraWeb.StaffRoles,
            index: %{"badges" => ["show"]},
            categories: %{"badges" => ["show"]},
            categories_new: %{"badges" => ["edit"]},
            categories_edit: %{"badges" => ["edit"]},
            conditions: %{"badges" => ["edit"]},
            conditions_new: %{"badges" => ["edit"]},
            conditions_edit: %{"badges" => ["edit"]},
            triggers: %{"badges" => ["edit"]},
            triggers_new: %{"badges" => ["edit"]},
            triggers_edit: %{"badges" => ["edit"]},
            new: %{"products" => ["edit"]},
            edit: %{"products" => ["edit"]},
            import: %{"badges" => ["edit"]}}

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

  defp apply_action(socket, :triggers, %{"id" => id}) do
    badge = Contest.get_badge!(id)

    socket
    |> assign(:page_title, "Listing #{badge.name} Triggers")
    |> assign(:badge, badge)
  end

  defp apply_action(socket, :triggers_edit, %{"id" => badge_id, "trigger_id" => trigger_id}) do
    socket
    |> assign(:page_title, "Edit Trigger")
    |> assign(:badge, Contest.get_badge!(badge_id))
    |> assign(:badge_trigger, Contest.get_badge_trigger!(trigger_id))
  end

  defp apply_action(socket, :triggers_new, %{"id" => id}) do
    socket
    |> assign(:page_title, "New Trigger")
    |> assign(:badge, Contest.get_badge!(id))
    |> assign(:badge_trigger, %BadgeTrigger{})
  end

  defp apply_action(socket, :import, _params) do
    socket
    |> assign(:page_title, "Import Badges")
  end

  defp apply_action(socket, :redeem, %{"id" => id}) do
    badge = Contest.get_badge!(id)

    socket
    |> assign(:page_title, "Redeem Badge")
    |> assign(:badge, badge)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    badge = Contest.get_badge!(id)
    {:ok, _} = Contest.delete_badge(badge)

    {:noreply, stream_delete(socket, :badges, badge)}
  end
end
