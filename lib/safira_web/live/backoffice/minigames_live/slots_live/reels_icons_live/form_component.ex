defmodule SafiraWeb.Backoffice.MinigamesLive.ReelIcons.FormComponent do
  @moduledoc false
  alias Safira.Minigames.SlotsReelIcon
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms
  import SafiraWeb.Components.ImageUploader

  alias Safira.Minigames

  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Reel Icons Configuration")}
        subtitle={gettext("Configures slots reel icons.")}
      >
        <div class="mt-8">
          <.simple_form
            id="slots-reels-config-form"
            for={@form}
            phx-submit="save"
            phx-change="validate"
            phx-target={@myself}
          >
            <div class="w-full">
              <.field_label>Upload Images</.field_label>
              <.image_uploader
                class="size-36 border-2 border-dashed"
                upload={@uploads.images}
                preview_disabled
                icon="hero-squares-plus"
              />
              <div class="mt-4 flex gap-4 overflow-x-auto p-2 border rounded-md">
                <%= for entry <- @uploads.images.entries do %>
                  <div class="relative group flex-shrink-0 bg-dark rounded-lg">
                    <.live_img_preview entry={entry} class="size-32 object-cover rounded-lg" />
                    <div class="absolute inset-0 flex items-center justify-center bg-primary bg-opacity-50 opacity-0 group-hover:opacity-100 rounded-lg">
                      <button
                        type="button"
                        class="text-white"
                        phx-click="cancel-upload"
                        phx-value-ref={entry.ref}
                        phx-target={@myself}
                      >
                        <.icon name="hero-x-mark" />
                      </button>
                    </div>
                    <%= for err <- upload_errors(@uploads.images, entry) do %>
                      <div class="mt-1 text-red-500 text-sm"><%= err %></div>
                    <% end %>
                  </div>
                <% end %>
                <%= if Enum.empty?(@uploads.images.entries) do %>
                  <div class="w-full h-32 rounded-lg flex items-center justify-center">
                    <span class="text-gray-400">No images uploaded</span>
                  </div>
                <% end %>
              </div>
            </div>
            <p class="text-slate-500">
              <.icon name="hero-exclamation-triangle" class="text-warning-600 mr-1" /><%= gettext(
                "Each icon should be a square image."
              ) %>
            </p>
            <div class="flex justify-end">
              <.button phx-disable-with="Saving..."><%= gettext("Save Configuration") %></.button>
            </div>
          </.simple_form>
        </div>
      </.page>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:reel, %SlotsReelIcon{})
     |> allow_upload(:images,
       accept: Uploaders.SlotsReelIcon.extension_whitelist(),
       max_entries: 15
     )
     |> assign(form: to_form(%{}))}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Minigames.change_slots_reel_icon(socket.assigns.reel))
     end)}
  end

  def handle_event("validate", %{"number_of_icons" => number_of_icons}, socket) do
    number = max(String.to_integer(number_of_icons), 1)
    changeset = Minigames.change_slots_reel_icon(socket.assigns.reel, %{number_of_icons: number})

    {:noreply,
     socket
     |> assign(:number_of_icons, number)
     |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("validate", params, socket) do
    changeset = Minigames.change_slots_reel_icon(socket.assigns.reel, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", _params, socket) do
    case consume_image_data(socket) do
      {:ok, _results} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reels created successfully")
         |> push_patch(to: ~p"/dashboard/minigames/slots")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  defp consume_image_data(socket) do
    Minigames.update_slots_reel_icons(
      socket.assigns.uploads.images.entries,
      socket
    )
  end
end
