defmodule SafiraWeb.App.HomeLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Accounts
  alias Safira.Uploaders.CV

  import SafiraWeb.Components.ImageUploader
  import SafiraWeb.Components.Forms

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
          <div class="w-full pb-6">
            <.field_label>Curriculum Vitae</.field_label>
            <.image_uploader
              class="h-full"
              upload={@uploads.cv}
              image={Uploaders.CV.url({@attendee.cv, @attendee}, :original)}
              icon="hero-check-badge"
            />
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
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
  def update(%{attendee: attendee} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounts.change_attendee(attendee))
     end)}
  end

  @impl true
  def handle_event("validate", %{"attendee" => attendee_params}, socket) do
    changeset = Accounts.change_attendee(socket.assigns.attendee, attendee_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"attendee" => attendee_params}, socket) do
    save_attendee(socket, attendee_params)
  end

  def handle_event("save", %{}, socket) do
    save_attendee(socket, %{})
  end

  defp save_attendee(socket, attendee_params) do
    case Accounts.update_attendee(socket.assigns.attendee, attendee_params) do
      {:ok, attendee} ->
        case consume_image_data(attendee, socket) do
          {:ok, _attendee} ->
            {:noreply,
             socket
             |> put_flash(:info, "Profile updated successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp consume_image_data(attendee, socket) do
    consume_uploaded_entries(socket, :cv, fn %{path: path}, entry ->
      Accounts.update_attendee_cv(attendee, %{
        "cv" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, attendee}] ->
        {:ok, attendee}

      _errors ->
        {:ok, attendee}
    end
  end
end
