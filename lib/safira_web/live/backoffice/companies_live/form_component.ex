defmodule SafiraWeb.Backoffice.CompanyLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Accounts.User
  alias Safira.Companies
  alias Safira.Uploaders.Company

  import SafiraWeb.Components.ImageUploader
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          <%= gettext("Companies sponsor the event.") %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="company-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div>
          <div class="grid grid-cols-2">
            <.field field={@form[:name]} type="text" label="Name" wrapper_class="pr-2" required />
            <.field field={@form[:url]} type="text" label="URL" wrapper_class="" />
            <.inputs_for :let={user} field={@form[:user]}>
              <.field field={user[:email]} type="email" label="Email" wrapper_class="pr-2" required />
              <.field
                field={user[:password]}
                type="password"
                label="Password"
                wrapper_class=""
                required={@action == :new}
              />
              <.field field={user[:handle]} type="text" label="Handle" wrapper_class="pr-2" required />
              <.field field={user[:name]} type="text" label="User name" wrapper_class="" required />
            </.inputs_for>

            <.field
              field={@form[:tier_id]}
              type="select"
              options={options(@tiers)}
              label="Tier"
              wrapper_class="pr-2"
              required
            />
            <.field
              field={@form[:badge_id]}
              type="select"
              options={options(@badges)}
              label="Badge"
              wrapper_class=""
            />
          </div>
          <div class="w-full">
            <.field_label>Logo</.field_label>
            <p class="text-sm mb-4">
              <%= gettext("For better results, upload a white logo with a transparent background.") %>
            </p>
            <.image_uploader
              class="w-full h-80"
              image_class="h-80 p-16 bg-dark hover:bg-dark/90 w-full transition-colors rounded-xl"
              icon="hero-building-office"
              upload={@uploads.logo}
              image={Uploaders.Company.url({@company.logo, @company}, :original, signed: true)}
            />
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Company</.button>
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
     |> allow_upload(:logo,
       accept: Company.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{company: company} = assigns, socket) do
    new_company = put_user(company)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:company, new_company)
     |> assign_new(:form, fn ->
       to_form(Companies.change_company(new_company))
     end)}
  end

  @impl true
  def handle_event("validate", %{"company" => company_params}, socket) do
    changeset = Companies.change_company(socket.assigns.company, company_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"company" => company_params}, socket) do
    save_company(socket, company_params)
  end

  defp save_company(socket, company_params) do
    case Companies.upsert_company_and_user(socket.assigns.company, company_params) do
      {:ok, company} ->
        case consume_image_data(company, socket) do
          {:ok, _company} ->
            {:noreply,
             socket
             |> put_flash(:info, "Company updated successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp consume_image_data(company, socket) do
    consume_uploaded_entries(socket, :logo, fn %{path: path}, entry ->
      Companies.update_company_logo(company, %{
        "logo" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, company}] ->
        {:ok, company}

      _errors ->
        {:ok, company}
    end
  end

  defp options(tiers) do
    [{gettext("None"), nil}] ++
      Enum.map(tiers, &{&1.name, &1.id})
  end

  defp put_user(company) do
    if is_nil(company.user_id) do
      Map.put(company, :user, %User{})
    else
      company
    end
  end
end
