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
                field={@form[:fee]}
                name="fee"
                type="number"
                help_text={
                  gettext(
                    "Fee in percentage that gets removed from the total bet. Must be a number between 0 and 100."
                  )
                }
              />
            </div>
            <div class="flex flex-row-reverse">
              <.button phx-disable-with="Saving..."><%= gettext("Save Configuration") %></.button>
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
             "fee" => Minigames.get_coin_flip_fee() * 100,
             "is_active" => Minigames.coin_flip_active?()
           },
           as: :coin_flip_configuration
         )
     )}
  end

  def handle_event("validate", params, socket) do
    changeset = validate_configuration(params["fee"], params["is_active"])

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :wheel_configuration))}
  end

  def handle_event("save", params, socket) do
    if valid_config?(params) do
      Minigames.change_coin_flip_fee((params["fee"] |> String.to_integer()) / 100)
      Minigames.change_coin_flip_active("true" == params["is_active"])
      {:noreply, socket |> push_patch(to: ~p"/dashboard/minigames/")}
    else
      {:noreply, socket}
    end
  end

  defp validate_configuration(fee, is_active) do
    {%{}, %{fee: :integer, is_active: :boolean}}
    |> Changeset.cast(%{fee: fee, is_active: is_active}, [:fee, :is_active])
    |> Changeset.validate_required([:fee])
    |> Changeset.validate_number(:fee, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

  defp valid_config?(params) do
    validation = validate_configuration(params["fee"], params["is_active"])
    validation.errors == []
  end
end
