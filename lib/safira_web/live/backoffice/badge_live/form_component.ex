defmodule SafiraWeb.Backoffice.BadgeLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Contest
  alias Safira.Uploaders.Badge

  import SafiraWeb.Components.ImageUploader
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
        subtitle={
          gettext(
            "Attendees can earn badges by participating in activities and challenges during the event."
          )
        }
      >
        <:actions>
          <.link :if={@badge.id} patch={~p"/dashboard/badges/#{@badge.id}/conditions"}>
            <.button>
              <.icon name="hero-check-circle" />
            </.button>
          </.link>
        </:actions>
        <.simple_form
          for={@form}
          id="badge-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="flex flex-col md:flex-row w-full gap-4">
            <div class="w-full space-y-2">
              <.field field={@form[:name]} type="text" label="Name" required />
              <.field field={@form[:description]} type="textarea" label="Description" required />
              <.field field={@form[:tokens]} type="number" label="Tokens" required />
              <.field field={@form[:entries]} type="number" label="Entries" required />
              <.field
                field={@form[:category_id]}
                options={categories_options(@categories)}
                type="select"
                label="Category"
                required
              />
              <.field field={@form[:begin]} type="datetime-local" label="Begin" required />
              <.field field={@form[:end]} type="datetime-local" label="End" required />
              <.field
                field={@form[:givable]}
                wrapper_class="pt-4"
                type="switch"
                label="Givable by staff"
                help_text={
                  gettext(
                    "Controls whether staffs can give this badge to attendees when the current time is between begin and end."
                  )
                }
              />
              <.field
                field={@form[:counts_for_day]}
                wrapper_class="pt-4"
                type="switch"
                label="Counts for day"
                help_text={
                  gettext(
                    "Controls whether tokens received by getting this badge count for the daily leaderboard."
                  )
                }
              />
            </div>
            <div class="w-full pb-6">
              <.field_label>Image</.field_label>
              <.image_uploader
                class="h-full"
                upload={@uploads.image}
                image={Uploaders.Badge.url({@badge.image, @badge}, :original, signed: true)}
                icon="hero-check-badge"
              />
            </div>
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Badge</.button>
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
     |> allow_upload(:image,
       accept: Badge.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{badge: badge} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Contest.change_badge(badge))
     end)}
  end

  @impl true
  def handle_event("validate", %{"badge" => badge_params}, socket) do
    changeset = Contest.change_badge(socket.assigns.badge, badge_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"badge" => badge_params}, socket) do
    save_badge(socket, socket.assigns.action, badge_params)
  end

  defp save_badge(socket, :edit, badge_params) do
    case Contest.update_badge(socket.assigns.badge, badge_params) do
      {:ok, badge} ->
        case consume_image_data(badge, socket) do
          {:ok, _badge} ->
            {:noreply,
             socket
             |> put_flash(:info, "Badge updated successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_badge(socket, :new, badge_params) do
    case Contest.create_badge(badge_params) do
      {:ok, badge} ->
        case consume_image_data(badge, socket) do
          {:ok, _badge} ->
            {:noreply,
             socket
             |> put_flash(:info, "Badge created successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp consume_image_data(badge, socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      Contest.update_badge_image(badge, %{
        "image" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, badge}] ->
        {:ok, badge}

      _errors ->
        {:ok, badge}
    end
  end

  defp categories_options(categories) do
    Enum.map(categories, &{&1.name, &1.id})
  end
end
