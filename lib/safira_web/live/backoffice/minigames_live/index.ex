defmodule SafiraWeb.Backoffice.MinigamesLive.Index do
  use SafiraWeb, :backoffice_view

  on_mount {SafiraWeb.StaffRoles,
            index: %{"minigames" => ["show"]},
            simulate_wheel: %{"minigames" => ["simulate"]},
            edit_wheel_drops: %{"minigames" => ["edit"]},
            edit_wheel: %{"minigames" => ["edit"]},
            edit_slots: %{"minigames" => ["edit"]},
            edit_slots_reel_icons_icons: %{"minigames" => ["edit"]},
            edit_slots_paytable: %{"minigames" => ["edit"]},
            edit_slots_payline: %{"minigames" => ["edit"]},
            edit_coin_flip: %{"minigames" => ["edit"]}}

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :minigames)}
  end

  def handle_params(_, _params, socket) do
    {:noreply, socket}
  end
end
