defmodule SafiraWeb.Backoffice.MinigamesLive.Simulator.Index do
  @moduledoc false
  use SafiraWeb, :live_component

  import SafiraWeb.App.WheelLive.Components.Wheel
  import SafiraWeb.App.WheelLive.Components.ResultModal
  import SafiraWeb.Components.Button

  alias Safira.Minigames

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Wheel")}
        subtitle={gettext("Spinning the wheel does not affect live data.")}
      >
        <div class="py-8 flex flex-col gap-12 items-center">
          <.wheel />

          <.action_button
            title={gettext("Simulate Spin")}
            phx-click="spin-wheel"
            disabled={@in_spin?}
            phx-target={@myself}
          />
        </div>
      </.page>

      <.result_modal
        :if={@result}
        drop_type={@result.type}
        drop={@result.drop}
        wrapper_class="px-6"
        content_class="dark:bg-dark bg-light dark:text-light text-dark"
        show
        show_vault_link={false}
        id="confirm"
        on_cancel={JS.push("close-modal", target: @myself)}
      />
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:current_page, :minigames)
     |> assign(:in_spin?, false)
     |> assign(:result, nil)}
  end

  @impl true
  def handle_event("spin-wheel", _params, socket) do
    {:noreply,
     socket
     # Set the wheel to spin mode
     |> assign(:in_spin?, true)
     |> push_event("spin-wheel", %{})}
  end

  @impl true
  def handle_event("get-prize", _params, socket) do
    case Minigames.simulate_wheel_spin() do
      {:ok, type, drop} ->
        {:noreply,
         socket
         |> assign(:result, %{type: type, drop: drop})
         # Reset wheel
         |> assign(:in_spin?, false)}
    end
  end

  @impl true
  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:result, nil)}
  end
end
