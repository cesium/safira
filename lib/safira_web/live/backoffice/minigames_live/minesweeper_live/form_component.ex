defmodule SafiraWeb.Backoffice.MinigamesLive.Minesweeper.FormComponent do
  @moduledoc false
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  alias Ecto.Changeset
  alias Safira.Minigames

  @max_house_edge floor(100 / Minigames.minesweeper_board_size())

  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Minesweeper Configuration")}
        subtitle={gettext("Configures minesweeper minigame's internal settings.")}
      >
        <div class="my-8">
          <.form
            id="minesweeper-config-form"
            for={@form}
            phx-submit="save"
            phx-change="validate"
            phx-target={@myself}
          >
            <div class="grid grid-cols-2 gap-4">
              <.field
                field={@form[:is_active]}
                name="is_active"
                label="Active"
                type="switch"
                help_text={gettext("Defines whether the minesweeper minigame is active.")}
                wrapper_class="my-6"
              />
              <div class="flex flex-col">
                <.field
                  field={@form[:max_multiplier]}
                  name="max_multiplier"
                  type="number"
                  help_text={
                    gettext(
                      "The highest possible payout multiplier an attendee can reach in a single round. Must be greater than 1."
                    )
                  }
                />

                <.field
                  field={@form[:house_edge]}
                  name="house_edge"
                  type="number"
                  help_text={
                    gettext(
                      "The percentage of total bets retained over time. Must be a number between 0 and %{max}.",
                      max: @max_house_edge
                    )
                  }
                />
              </div>
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
     |> assign(:max_house_edge, @max_house_edge)
     |> assign(
       form:
         to_form(
           %{
             "max_multiplier" => Minigames.get_minesweeper_max_multiplier(),
             "house_edge" => round(Minigames.get_minesweeper_house_edge() * 100),
             "is_active" => Minigames.minesweeper_active?()
           },
           as: :minesweeper_configuration
         )
     )}
  end

  def handle_event("validate", params, socket) do
    changeset =
      validate_configuration(params["max_multiplier"], params["house_edge"], params["is_active"])

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :minesweeper_configuration))}
  end

  def handle_event("save", params, socket) do
    if valid_config?(params) do
      Minigames.change_minesweeper_max_multiplier(params["max_multiplier"] |> String.to_integer())
      Minigames.change_minesweeper_house_edge((params["house_edge"] |> String.to_integer()) / 100)
      Minigames.change_minesweeper_active("true" == params["is_active"])
      {:noreply, socket |> push_patch(to: ~p"/dashboard/minigames/")}
    else
      {:noreply, socket}
    end
  end

  defp validate_configuration(max_multiplier, house_edge, is_active) do
    {%{}, %{max_multiplier: :integer, house_edge: :integer, is_active: :boolean}}
    |> Changeset.cast(
      %{max_multiplier: max_multiplier, house_edge: house_edge, is_active: is_active},
      [:max_multiplier, :house_edge, :is_active]
    )
    |> Changeset.validate_required([:max_multiplier, :house_edge])
    |> Changeset.validate_number(:max_multiplier, greater_than: 1)
    |> Changeset.validate_number(:house_edge,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: @max_house_edge
    )
  end

  defp valid_config?(params) do
    validation =
      validate_configuration(params["max_multiplier"], params["house_edge"], params["is_active"])

    validation.errors == []
  end
end
