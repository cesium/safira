defmodule SafiraWeb.Backoffice.CompanyLive.Index do
  use SafiraWeb, :backoffice_view

  import SafiraWeb.Components.{Table, TableSearch}

  alias Safira.Companies
  alias Safira.Companies.{Company, Tier}

  on_mount {SafiraWeb.StaffRoles, index: %{"companies" => ["edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Companies.list_companies(params) do
      {:ok, {companies, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :companies)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:companies, companies, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Company")
    |> assign(:badge, Companies.get_company!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Company")
    |> assign(:badge, %Company{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Companies")
  end

  defp apply_action(socket, :tiers_edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tier")
    |> assign(:category, Companies.get_tier!(id))
  end

  defp apply_action(socket, :tiers_new, _params) do
    socket
    |> assign(:page_title, "New Tier")
    |> assign(:category, %Tier{})
  end

  defp apply_action(socket, :tiers, _params) do
    socket
    |> assign(:page_title, "Listing Sponsor Tiers")
  end
end
