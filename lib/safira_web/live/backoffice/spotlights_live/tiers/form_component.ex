defmodule SafiraWeb.Backoffice.SpotlightLive.Tiers.FormComponent do
  @moduledoc """
  A LiveComponent for managing the spotlight configuration in the backoffice.

  This component renders a form for updating the spotlight duration and handles the form submission of the tier configuration.

  """
  use SafiraWeb, :live_component

  alias Safira.Companies
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <.simple_form for={@form} id="tier-form" phx-target={@myself} phx-submit="save">
          <div class="w-full space-y-2">
            <.field field={@form[:spotlight_multiplier]} type="number" label="Multiplier" required />
          </div>
          <div>
            <.field field={@form[:max_spotlights]} type="number" label="Max Spotlights" required />
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save</.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{tier: tier} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:action, fn -> :tiers_edit end)
     |> assign_new(:form, fn ->
       to_form(Companies.change_tier_multiplier(tier))
     end)}
  end

  @impl true
  def handle_event("validate", %{"tier" => tier_params}, socket) do
    changeset = Companies.change_tier_multiplier(socket.assigns.tier, tier_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tier" => tier_params}, socket) do
    action = socket.assigns[:action] || :tiers_edit
    save_tier(socket, action, tier_params["spotlight_multiplier"], tier_params["max_spotlights"])
  end

  defp save_tier(socket, :tiers_edit, spotlight_multiplier, max_spotlights) do
    case Companies.update_tier_spotlight_configuration(
           socket.assigns.tier,
           spotlight_multiplier,
           max_spotlights
         ) do
      {:ok, _tier} ->
        {:noreply,
         socket
         |> put_flash(:info, "Company tier updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
