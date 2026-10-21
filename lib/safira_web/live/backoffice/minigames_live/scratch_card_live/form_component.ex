defmodule SafiraWeb.Backoffice.MinigamesLive.ScratchCard.FormComponent do
  @moduledoc false
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  alias Ecto.Changeset
  alias Safira.Minigames

  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Scratch Card Configuration")}
        subtitle={gettext("Configures scratch card minigame's internal settings.")}
      >
        <:actions>
          <.link navigate={~p"/dashboard/minigames/scratch_card/drops"}>
            <.button>
              <.icon name="hero-table-cells" class="w-5" />
            </.button>
          </.link>
        </:actions>

        <:actions>
          <.link navigate={~p"/dashboard/minigames/scratch_card/symbols"}>
            <.button>
              <.icon name="hero-star" class="w-5" />
            </.button>
          </.link>
        </:actions>

        <div class="my-8">
          <.form
            id="scratch-card-config-form"
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
                help_text={gettext("Defines whether the scratch card minigame is active.")}
                wrapper_class="my-6"
              />
              <.field
                field={@form[:price]}
                name="price"
                type="number"
                help_text={
                  gettext("Price in tokens that attendees need to pay to buy a scratch card.")
                }
              />
            </div>
            <div class="flex flex-row-reverse">
              <.button phx-disable-with="Saving...">{gettext("Save Configuration")}</.button>
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
           %{
             "price" => Minigames.get_scratch_card_price(),
             "is_active" => Minigames.scratch_card_active?()
           },
           as: :scratch_card_configuration
         )
     )}
  end

  def handle_event("validate", params, socket) do
    changeset = validate_configuration(params["price"], params["is_active"])

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :scratch_card_configuration))}
  end

  def handle_event("save", params, socket) do
    if valid_config?(params) do
      Minigames.change_scratch_card_price(params["price"] |> String.to_integer())
      Minigames.change_scratch_card_active("true" == params["is_active"])
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

  defp valid_config?(params) do
    validation = validate_configuration(params["price"], params["is_active"])
    validation.errors == []
  end
end
