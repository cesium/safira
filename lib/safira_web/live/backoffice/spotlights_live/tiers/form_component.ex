defmodule SafiraWeb.Backoffice.SpotlightLive.Tiers.FormComponent do
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
            <.field field={@form[:multiplier]} type="number" label="Multiplier" required />
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
    IO.inspect(tier)

    {:ok,
     socket
     |> assign(assigns)
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
    save_tier(socket, socket.assigns.action, tier_params.multiplier)
  end

  defp save_tier(socket, :tiers_edit, multiplier) do
    case Companies.update_tier_multiplier(socket.assigns.tier, multiplier) do
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
