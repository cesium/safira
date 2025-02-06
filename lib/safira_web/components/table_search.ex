defmodule SafiraWeb.Components.TableSearch do
  @moduledoc """
  Reusable table search component.
  """
  use Phoenix.Component
  use Gettext, backend: SafiraWeb.Gettext

  attr :id, :string, required: true
  attr :params, :map, required: true
  attr :field, :atom, required: true
  attr :path, :string, required: true
  attr :placeholder, :string, default: gettext("Search")
  attr :class, :string, default: ""

  def table_search(assigns) do
    ~H"""
    <.live_component
      id={@id}
      module={SafiraWeb.Components.TableSearchLiveComponent}
      params={@params}
      field={@field}
      path={@path}
      placeholder={@placeholder}
      class={@class}
    />
    """
  end
end

defmodule SafiraWeb.Components.TableSearchLiveComponent do
  @moduledoc """
  Live component for the TableSearch component.
  """
  use Phoenix.LiveComponent

  alias Plug.Conn.Query
  import SafiraWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative">
      <div class="absolute inset-y-0 left-0 rtl:inset-r-0 rtl:right-0 flex items-center ps-3 pointer-events-none">
        <.icon class="w-5 h-5 text-darkMuted dark:text-lightMuted" name="hero-magnifying-glass" />
      </div>
      <form phx-submit="search" phx-change="search" method="#" phx-target={@myself}>
        <input
          type="search"
          name="search[query]"
          spellcheck="false"
          value={@search_value}
          placeholder={@placeholder}
          class={"block w-full sm:w-80 p-2 ps-10 text-sm text-dark border border-lightShade rounded-md placeholder:text-darkMuted focus:outline-2 focus:border-lightShade ring-0 focus:outline-dark focus:outline-offset-2 dark:outline-darkShade dark:bg-dark dark:text-light dark:placeholder-lightMuted dark:focus:border-darkShade dark:focus:border-darkShade dark:border-darkShade focus:ring-0 dark:focus:outline-light #{@class}"}
        />
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    search_value = assigns.params["filters"]["1"]["value"] || ""

    {:ok,
     socket
     |> assign(:search_value, search_value)
     |> assign(assigns)}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    params = build_filter_map(socket.assigns.params, query, socket.assigns.field)

    {:noreply, push_patch(socket, to: socket.assigns.path <> "?#{Query.encode(params)}")}
  end

  defp build_filter_map(params, value, field) do
    filters =
      (params["filters"] || %{})
      |> Map.put("1", %{
        "field" => field |> Atom.to_string(),
        "value" => value,
        "op" => "ilike_or"
      })

    Map.put(params, "filters", filters)
    |> Map.put("page", 1)
  end
end
