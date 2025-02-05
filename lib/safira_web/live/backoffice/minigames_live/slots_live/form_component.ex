defmodule SafiraWeb.Backoffice.MinigamesLive.Slots.FormComponent do
  @moduledoc false
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  alias Ecto.Changeset
  alias Safira.Minigames

  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Slots Configuration")}
        subtitle={gettext("Configures slots minigame's internal settings.")}
      >
        <:actions>
          <.link navigate={~p"/dashboard/minigames/slots/reels_icons"}>
            <.button>
              <.icon name="hero-star" class="w-5" />
            </.button>
          </.link>
          <.link navigate={~p"/dashboard/minigames/slots/reels_position"}>
            <.button>
              <.icon name="hero-view-columns" class="w-5" />
            </.button>
          </.link>
          <.link navigate={~p"/dashboard/minigames/slots/paytable"}>
            <.button>
              <.icon name="hero-circle-stack" class="w-5" />
            </.button>
          </.link>
          <.link navigate={~p"/dashboard/minigames/slots/payline"}>
            <.button>
              <.icon name="hero-rectangle-stack" class="w-5" />
            </.button>
          </.link>
        </:actions>
        <div class="my-8">
          <.form
            id="slots-config-form"
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
                help_text={gettext("Defines whether the slots minigame is active.")}
                wrapper_class="my-6"
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
             "is_active" => Minigames.slots_active?()
           },
           as: :slots_configuration
         )
     )}
  end

  def handle_event("validate", params, socket) do
    changeset = validate_configuration(params["is_active"])

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :wheel_configuration))}
  end

  def handle_event("save", params, socket) do
    if valid_config?(params) do
      Minigames.change_slots_active("true" == params["is_active"])
      {:noreply, socket |> push_patch(to: ~p"/dashboard/minigames/")}
    else
      {:noreply, socket}
    end
  end

  defp validate_configuration(is_active) do
    {%{}, %{is_active: :boolean}}
    |> Changeset.cast(%{is_active: is_active}, [:is_active])
  end

  defp valid_config?(params) do
    validation = validate_configuration(params["is_active"])
    validation.errors == []
  end
end
