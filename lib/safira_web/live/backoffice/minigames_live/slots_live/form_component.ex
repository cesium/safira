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
          <div class="flex gap-10 mt-4 text-center">
            <.link
              patch={~p"/dashboard/minigames/slots/reels_icons"}
              class="flex flex-col items-center justify-center w-full text-2xl gap-4 font-semibold py-8 rounded-2xl dark:bg-darkShade/10 dark:hover:bg-darkShade/20 bg-lightShade/30 hover:bg-lightShade/40 transition-colors"
            >
              <%= gettext("Edit reels icons") %>
            </.link>

            <.link
              patch={~p"/dashboard/minigames/slots/reels_position"}
              class="flex flex-col items-center justify-center w-full text-2xl gap-4 font-semibold py-8 rounded-2xl dark:bg-darkShade/10 dark:hover:bg-darkShade/20 bg-lightShade/30 hover:bg-lightShade/40 transition-colors"
            >
              <%= gettext("Edit reels position") %>
            </.link>

            <.link
              patch={~p"/dashboard/minigames/slots/paytable"}
              class="flex flex-col items-center justify-center w-full text-2xl gap-4 font-semibold py-8 rounded-2xl dark:bg-darkShade/10 dark:hover:bg-darkShade/20 bg-lightShade/30 hover:bg-lightShade/40 transition-colors"
            >
              <%= gettext("Edit paytable") %>
            </.link>

            <.link
              patch={~p"/dashboard/minigames/slots/payline"}
              class="flex flex-col items-center justify-center w-full text-2xl gap-4 font-semibold py-8 rounded-2xl dark:bg-darkShade/10 dark:hover:bg-darkShade/20 bg-lightShade/30 hover:bg-lightShade/40 transition-colors"
            >
              <%= gettext("Edit payline") %>
            </.link>
          </div>
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
