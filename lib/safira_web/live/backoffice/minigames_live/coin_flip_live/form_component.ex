defmodule SafiraWeb.Backoffice.MinigamesLive.CoinFlip.FormComponent do
  @moduledoc false
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  alias Ecto.Changeset
  alias Safira.Minigames

  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Coin Flip Configuration")}
        subtitle={gettext("Configures coin flip minigame's internal settings.")}
      >
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
                help_text={gettext("Defines whether the coin flip minigame is active.")}
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
           %{"price" => Minigames.get_coin_flip_fee(), "is_active" => Minigames.wheel_active?()},
           as: :coin_flip_configuration
         )
     )}
  end

  def handle_event("validate", params, socket) do
    changeset = validate_configuration(params["price"], params["is_active"])

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :wheel_configuration))}
  end

  def handle_event("save", params, socket) do
    if valid_config?(params) do
      Minigames.change_coin_flip_fee(params["price"] |> String.to_integer())
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

  defp valid_config?(params) do
    validation = validate_configuration(params["price"], params["is_active"])
    validation.errors == []
  end
end
