defmodule SafiraWeb.Backoffice.CompanyLive.TierLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Companies
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
        subtitle={gettext("Every company sponsoring the event gets assigned a tier.")}
      >
        <.simple_form
          for={@form}
          id="tier-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full space-y-2">
            <.field field={@form[:name]} type="text" label="Name" required />
            <.field field={@form[:full_cv_access]} type="switch" label="Full CV Access" />
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Tier</.button>
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
     |> assign_new(:form, fn ->
       to_form(Companies.change_tier(tier))
     end)}
  end

  @impl true
  def handle_event("validate", %{"tier" => tier_params}, socket) do
    changeset = Companies.change_tier(socket.assigns.tier, tier_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tier" => tier_params}, socket) do
    save_tier(socket, socket.assigns.action, tier_params)
  end

  defp save_tier(socket, :tiers_edit, tier_params) do
    case Companies.update_tier(socket.assigns.tier, tier_params) do
      {:ok, _tier} ->
        {:noreply,
         socket
         |> put_flash(:info, "Company tier updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tier(socket, :tiers_new, tier_params) do
    case Companies.create_tier(
           tier_params
           |> Map.put("priority", Companies.get_next_tier_priority())
         ) do
      {:ok, _tier} ->
        {:noreply,
         socket
         |> put_flash(:info, "Company tier created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
