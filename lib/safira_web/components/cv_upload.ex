defmodule SafiraWeb.Components.CVUpload do
  @moduledoc """
  Attendee Curriculum Vitae upload component.
  """
  use SafiraWeb, :live_component

  alias Safira.Accounts
  alias Safira.Uploaders.CV

  import SafiraWeb.Components.ImageUploader
  import SafiraWeb.Components.Button

  attr :in_app, :boolean, default: false

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="attendee-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="flex flex-col md:flex-row w-full gap-4">
          <div class="w-full">
            <.image_uploader class="h-40" upload={@uploads.cv}>
              <:placeholder>
                <div class="select-none flex flex-col gap-2 items-center text-lightMuted dark:text-darkMuted">
                  <.icon name="hero-arrow-up-tray" class="w-12 h-12" />
                  <p class="px-4 text-center">Upload your Curriculum Vitae</p>
                </div>
              </:placeholder>
            </.image_uploader>
          </div>
        </div>
        <:actions>
          <%= if @in_app do %>
            <.action_button title="Upload" phx-disable-with="Uploading..." />
          <% else %>
            <.button phx-disable-with="Uploading...">Upload</.button>
          <% end %>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:cv,
       accept: CV.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{current_user: user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounts.change_user_profile(user))
     end)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{}, socket) do
    save_user(socket, %{})
  end

  defp save_user(socket, user_params) do
    case Accounts.update_user(socket.assigns.current_user, user_params) do
      {:ok, user} ->
        case consume_pdf_data(user, socket) do
          {:ok, _user} ->
            {:noreply,
             socket
             |> put_flash(:info, "CV uploaded successfully.")
             |> push_patch(to: socket.assigns.patch)}

          {:error, reason} ->
            {:noreply,
             socket |> put_flash(:error, reason) |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp consume_pdf_data(user, socket) do
    consume_uploaded_entries(socket, :cv, fn %{path: path}, entry ->
      Accounts.update_user_cv(user, %{
        "cv" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [] ->
        {:error, "Select a file to upload."}

      [{:ok, user}] ->
        {:ok, user}

      _errors ->
        {:ok, user}
    end
  end
end
