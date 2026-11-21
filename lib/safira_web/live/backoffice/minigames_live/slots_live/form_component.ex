defmodule SafiraWeb.Backoffice.MinigamesLive.Slots.FormComponent do
  @moduledoc false
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  alias Ecto.Changeset
  alias Safira.Minigames

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {gettext("Slots Configuration")}
        <:subtitle>{gettext("Configures slots minigame's internal settings.")}</:subtitle>
      </.header>
      <div class="mt-4 flex flex-wrap gap-2">
        <.link navigate={~p"/dashboard/minigames/slots/reels_icons"}>
          <.button class="flex items-center gap-2">
            <.icon name="hero-star" class="w-5" />
            {gettext("Reel icons")}
          </.button>
        </.link>
        <.link navigate={~p"/dashboard/minigames/slots/reels_position"}>
          <.button class="flex items-center gap-2">
            <.icon name="hero-view-columns" class="w-5" />
            {gettext("Reel positions")}
          </.button>
        </.link>
        <.link navigate={~p"/dashboard/minigames/slots/paytable"}>
          <.button class="flex items-center gap-2">
            <.icon name="hero-circle-stack" class="w-5" />
            {gettext("Paytable")}
          </.button>
        </.link>
        <.link navigate={~p"/dashboard/minigames/slots/payline"}>
          <.button class="flex items-center gap-2">
            <.icon name="hero-rectangle-stack" class="w-5" />
            {gettext("Paylines")}
          </.button>
        </.link>
      </div>
      <div class="mt-8">
        <.form
          id="slots-config-form"
          for={@form}
          phx-submit="save"
          phx-change="validate"
          phx-target={@myself}
        >
          <div class="grid grid-cols-1 gap-x-6 sm:grid-cols-2">
            <.field
              field={@form[:is_active]}
              name="is_active"
              label="Active"
              type="switch"
              help_text={gettext("Defines whether the slots minigame is active.")}
            />
          </div>
          <div class="flex flex-row-reverse">
            <.button phx-disable-with="Saving...">{gettext("Save Configuration")}</.button>
          </div>
        </.form>
      </div>
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
