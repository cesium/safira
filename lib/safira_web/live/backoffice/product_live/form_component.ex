defmodule SafiraWeb.ProductLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Store
  import SafiraWeb.Components.ImageUploader
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          <%= gettext(
            "Products can be purchased with tokens by attendees trough the event's digital store."
          ) %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="flex flex-col md:flex-row w-full gap-4">
          <div class="w-full space-y-2">
            <.field field={@form[:name]} type="text" label="Name" required />
            <.field field={@form[:description]} type="textarea" label="Description" required />
            <.field field={@form[:price]} type="number" label="Price" required />
            <.field field={@form[:stock]} type="number" label="Stock" required />
            <.field field={@form[:max_per_user]} type="number" label="Max per user" required />
          </div>
          <div class="w-full pb-6">
            <.field_label>Image</.field_label>
            <.image_uploader
              class="w-full h-full"
              upload={@uploads.image}
              image={Uploaders.Product.url({@product.image, @product}, :original)}
            />
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
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
       accept: Safira.Uploaders.Product.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Store.change_product(product))
     end)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset = Store.change_product(socket.assigns.product, product_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  defp save_product(socket, :edit, product_params) do
    case Store.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        case consume_image_data(product, socket) do
          {:ok, product} ->
            notify_parent({:saved, product})

            {:noreply,
             socket
             |> put_flash(:info, "Product updated successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Store.create_product(product_params) do
      {:ok, product} ->
        case consume_image_data(product, socket) do
          {:ok, product} ->
            notify_parent({:saved, product})

            {:noreply,
             socket
             |> put_flash(:info, "Product created successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp consume_image_data(product, socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      Store.update_product_image(product, %{
        "image" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, product}] ->
        {:ok, product}

      _errors ->
        {:ok, product}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
