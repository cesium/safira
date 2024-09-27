defmodule SafiraWeb.Backoffice.MinigamesLive.Wheel.FormComponent do
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  alias Safira.Minigames
  alias Ecto.Changeset

  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Lucky Wheel Configuration")}
        subtitle={gettext("Configures lucky wheel minigame's internal settings.")}
      >
        <:actions>
          <.link navigate={~p"/dashboard/minigames/wheel/drops"}>
            <.button>
              <.icon name="hero-table-cells" class="w-5" />
            </.button>
          </.link>
        </:actions>
        <div class="my-8">
          <.form
            id="wheel-config-form"
            for={@form}
            phx-submit="save"
            phx-change="validate"
            phx-target={@myself}
          >
            <div class="grid grid-cols-2">
              <.field
                field={@form[:is_active]}
                name="is_active"
                label="Active"
                type="switch"
                help_text={gettext("Defines whether the wheel minigame is active.")}
                wrapper_class="my-6"
              />
              <.field
                field={@form[:price]}
                name="price"
                type="number"
                help_text={
                  gettext("Price in tokens that attendees need to pay to spin the lucky wheel.")
                }
              />
            </div>
            <div class="flex flex-row-reverse">
              <.button phx-disable-with="Saving...">Save Configuration</.button>
            </div>
          </.form>
        </div>
      </.page>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       form:
         to_form(
           %{"price" => Minigames.get_wheel_price(), "is_active" => Minigames.is_wheel_active?()},
           as: :wheel_configuration
         )
     )}
  end

  def handle_event("validate", params, socket) do
    changeset = validate_configuration(params["price"], params["is_active"])

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :wheel_configuration))}
  end

  def handle_event("save", params, socket) do
    if is_valid_config?(params) do
      Minigames.change_wheel_price(params["price"] |> String.to_integer())
      Minigames.change_wheel_active("true" == params["is_active"])
      {:noreply, socket |> push_patch(to: ~p"/dashboard/minigames/")}
    else
      {:noreply, socket}
    end
  end

  defp validate_configuration(price, is_active) do
    {%{}, %{price: :integer, is_active: :boolean}}
    |> Changeset.cast(%{price: price, is_active: is_active}, [:price, :is_active])
    |> Changeset.validate_required([:price])
    |> Changeset.validate_number(:price, greater_than_or_equal_to: 0)
  end

  defp is_valid_config?(params) do
    validation = validate_configuration(params["price"], params["is_active"])
    validation.errors == []
  end
end
