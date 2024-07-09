defmodule SafiraWeb.Components.TableSearch do
  use Phoenix.Component
  import SafiraWeb.Gettext

  attr :id, :string, required: true
  attr :params, :map, required: true
  attr :field, :atom, required: true
  attr :path, :string, required: true
  attr :placeholder, :string, default: gettext("Search")
  def table_search(assigns) do
    ~H"""
      <.live_component
        id={@id}
        module={SafiraWeb.Components.TableSearchLiveComponent}
        params={@params}
        field={@field}
        path={@path}
        placeholder={@placeholder}/>
    """
  end
end

defmodule SafiraWeb.Components.TableSearchLiveComponent do
  use Phoenix.LiveComponent

  alias Plug.Conn.Query
  import SafiraWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
     <div class="relative">
      <div class="absolute inset-y-0 left-0 rtl:inset-r-0 rtl:right-0 flex items-center ps-3 pointer-events-none">
          <.icon class="w-5 h-5 text-gray-500 dark:text-gray-400" name="hero-magnifying-glass" />
      </div>
      <form phx-submit="search" phx-change="search" method="#" phx-target={@myself}>
        <input
          type="search"
          name="search[query]"
          spellcheck="false"
          placeholder={@placeholder}
          class="block p-2 ps-10 text-sm text-gray-900 border border-gray-300 rounded-lg w-80 bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        />
      </form>
    </div>
    """
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    params = build_filter_map(socket.assigns.params, query, socket.assigns.field)

    {:noreply, push_patch(socket, to: socket.assigns.path <> "?#{Query.encode(params)}")}
  end

  defp build_filter_map(params, value, field) do
    filters =
      (params["filters"] || %{})
      |> Map.put("1", %{"field" => field |> Atom.to_string(), "value" => value, "op" => "ilike_or"})

    Map.put(params, "filters", filters)
  end
end
