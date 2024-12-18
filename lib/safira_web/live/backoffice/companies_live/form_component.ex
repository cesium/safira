defmodule SafiraWeb.Backoffice.CompanyLive.FormComponent do
  use SafiraWeb, :live_component

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
              required
            />
          </div>
          <div class="w-full">
            <.field_label>Logo</.field_label>
            <.image_uploader
              class="w-full h-80"
              image_class="h-80"
              icon="hero-building-office"
              upload={@uploads.logo}
              image={Uploaders.Company.url({@company.logo, @company}, :original)}
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
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Companies.change_company(company))
     end)}
  end

  @impl true
  def handle_event("validate", %{"company" => company_params}, socket) do
    changeset = Companies.change_company(socket.assigns.company, company_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"company" => company_params}, socket) do
    save_company(socket, socket.assigns.action, company_params)
  end

  defp save_company(socket, :edit, company_params) do
    case Companies.update_company(socket.assigns.company, company_params) do
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

  defp save_company(socket, :new, company_params) do
    case Companies.create_company(company_params) do
      {:ok, company} ->
        case consume_image_data(company, socket) do
          {:ok, _company} ->
            {:noreply,
             socket
             |> put_flash(:info, "Company created successfully")
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
    Enum.map(tiers, &{&1.name, &1.id})
  end
end
