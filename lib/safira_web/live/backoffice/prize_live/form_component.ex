defmodule SafiraWeb.PrizeLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Minigames
  alias Safira.Uploaders.Prize

  import SafiraWeb.Components.ImageUploader
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          Prizes can be awarded to attendees via the app's various minigames.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="prize-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div>
          <div class="grid grid-cols-4 space-x-4">
            <.field field={@form[:name]} type="text" label="Name" wrapper_class="col-span-3" />
            <.field field={@form[:stock]} type="number" label="Stock" />
          </div>
          <div class="w-full">
            <.field_label>Image</.field_label>
            <.image_uploader
              class="w-full h-80"
              image_class="h-80"
              icon="hero-gift"
              upload={@uploads.image}
              image={Uploaders.Prize.url({@prize.image, @prize}, :original, signed: true)}
            />
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Prize</.button>
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
     |> allow_upload(:image,
       accept: Prize.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{prize: prize} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Minigames.change_prize(prize))
     end)}
  end

  @impl true
  def handle_event("validate", %{"prize" => prize_params}, socket) do
    changeset = Minigames.change_prize(socket.assigns.prize, prize_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"prize" => prize_params}, socket) do
    save_prize(socket, socket.assigns.action, prize_params)
  end

  defp save_prize(socket, :edit, prize_params) do
    case Minigames.update_prize(socket.assigns.prize, prize_params) do
      {:ok, prize} ->
        case consume_image_data(prize, socket) do
          {:ok, _prize} ->
            {:noreply,
             socket
             |> put_flash(:info, "Prize updated successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_prize(socket, :new, prize_params) do
    case Minigames.create_prize(prize_params) do
      {:ok, prize} ->
        case consume_image_data(prize, socket) do
          {:ok, _prize} ->
            {:noreply,
             socket
             |> put_flash(:info, "Prize created successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp consume_image_data(prize, socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      Minigames.update_prize_image(prize, %{
        "image" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, prize}] ->
        {:ok, prize}

      _errors ->
        {:ok, prize}
    end
  end
end
