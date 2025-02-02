defmodule SafiraWeb.Live.Backoffice.EventLive.TeamsLive.MemberLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Teams
  alias Safira.Uploaders.Member

  import SafiraWeb.Components.Forms
  import SafiraWeb.Components.ImageUploader

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Manage your team members here.")}>
        <.simple_form
          for={@form}
          id="member-form"
          phx-target={@myself}
          phx-submit="save"
          phx-change="validate"
        >
          <div class="w-full space-y-2">
            <.field field={@form[:name]} name="member[name]" type="text" label="Member Name" required />
          </div>
          <div class="w-full pb-6">
            <.field_label>Image</.field_label>
            <.image_uploader
              class="h-full"
              upload={@uploads.image}
              image={Uploaders.Member.url({@member.image, @member}, :original, signed: true)}
              icon="hero-photo"
            />
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save</.button>
            <.link
              phx-click={JS.push("delete", value: %{id: @member.id})}
              data-confirm="Are you sure?"
              phx-target={@myself}
            >
              <.icon name="hero-trash" class="w-5 h-5" />
            </.link>
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
       accept: Member.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{member: member} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Teams.change_team_member(member))
     end)}
  end

  @impl true
  def handle_event("save", %{"member" => member_params}, socket) do
    if socket.assigns.member do
      save_member(socket, :teams_members_edit, member_params)
    else
      member_params = Map.put(member_params, "team_id", socket.assigns.member.team_id)
      save_member(socket, :members_new, member_params)
    end
  end

  @impl true
  def handle_event("validate", %{"member" => member_params}, socket) do
    changeset = Teams.change_team_member(socket.assigns.member, member_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("delete", %{"team_id" => team_id}, socket) do
    member = Teams.get_team_member!(team_id)

    case Teams.delete_team_member(member) do
      {:ok, _member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member deleted successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Failed to delete member")}
    end
  end

  defp save_member(socket, :teams_members_edit, member_params) do
    case Teams.update_team_member(socket.assigns.member, member_params) do
      {:ok, _member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:form, to_form(changeset))}
    end
  end

  defp save_member(socket, :members_new, member_params) do
    case Teams.create_team_member(member_params) do
      {:ok, member} ->
        case consume_image_data(member, socket) do
          {:ok, member} ->
            {:noreply,
             socket
             |> assign(:member, member)
             |> put_flash(:info, "Member created successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end

  defp consume_image_data(member, socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      Teams.update_team_member_foto(member, %{
        "image" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, member}] ->
        {:ok, member}

      _errors ->
        {:ok, member}
    end
  end
end
