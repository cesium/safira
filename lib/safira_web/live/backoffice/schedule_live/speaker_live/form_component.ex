defmodule SafiraWeb.Backoffice.ScheduleLive.SpeakerLive.FormComponent do
  alias Safira.Activities
  use SafiraWeb, :live_component

  alias Safira.Uploaders.Speaker

  import SafiraWeb.Components.{Forms, ImageUploader}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Speakers participate in the event's activities.")}>
        <.simple_form
          for={@form}
          id="speaker-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full">
            <.field field={@form[:name]} type="text" label="Name" required />
            <div class="flex w-full gap-2">
              <.field
                field={@form[:company]}
                type="text"
                label="Company"
                wrapper_class="w-full"
                required
              />
              <.field field={@form[:title]} type="text" label="Title" wrapper_class="w-full" required />
            </div>
            <.field field={@form[:biography]} type="textarea" label="Biography" />
            <div class="grid grid-cols-3 gap-8">
              <div class="grid grid-cols-2 gap-2 col-span-2">
                <.inputs_for :let={socials_form} field={@form[:socials]}>
                  <.field
                    field={socials_form[:github]}
                    type="text"
                    label="GitHub"
                    wrapper_class="w-full"
                  />
                  <.field
                    field={socials_form[:linkedin]}
                    type="text"
                    label="LinkedIn"
                    wrapper_class="w-full"
                  />
                  <.field
                    field={socials_form[:website]}
                    type="text"
                    label="Website"
                    wrapper_class="w-full"
                  />
                  <.field field={socials_form[:x]} type="text" label="X" wrapper_class="w-full" />
                </.inputs_for>
                <.field
                  field={@form[:highlighted]}
                  type="switch"
                  label="Highlighted"
                  wrapper_class="w-full"
                />
              </div>
              <div class="flex flex-col gap-2">
                <.label>
                  <%= gettext("Picture") %>
                </.label>
                <.image_uploader
                  class="w-full aspect-square"
                  upload={@uploads.picture}
                  icon="hero-user"
                  image={Uploaders.Speaker.url({@speaker.picture, @speaker}, :original, signed: true)}
                />
              </div>
            </div>
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Speaker</.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:picture,
       accept: Speaker.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{speaker: speaker} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Activities.change_speaker(speaker))
     end)}
  end

  @impl true
  def handle_event("validate", %{"speaker" => speaker_params}, socket) do
    changeset = Activities.change_speaker(socket.assigns.speaker, speaker_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"speaker" => speaker_params}, socket) do
    save_speaker(socket, socket.assigns.action, speaker_params)
  end

  defp save_speaker(socket, :speakers_edit, speaker_params) do
    case Activities.update_speaker(socket.assigns.speaker, speaker_params) do
      {:ok, speaker} ->
        case consume_picture_data(speaker, socket) do
          {:ok, _speaker} ->
            {:noreply,
             socket
             |> put_flash(:info, "Speaker updated successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_speaker(socket, :speakers_new, speaker_params) do
    case Activities.create_speaker(speaker_params) do
      {:ok, speaker} ->
        case consume_picture_data(speaker, socket) do
          {:ok, _speaker} ->
            {:noreply,
             socket
             |> put_flash(:info, "Speaker created successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp consume_picture_data(speaker, socket) do
    consume_uploaded_entries(socket, :picture, fn %{path: path}, entry ->
      Activities.update_speaker_picture(speaker, %{
        "picture" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, speaker}] ->
        {:ok, speaker}

      _errors ->
        {:ok, speaker}
    end
  end
end
