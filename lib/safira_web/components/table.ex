defmodule SafiraWeb.Components.Table do
  @moduledoc """
  Table component for displaying data in a tabular format.
  """
  use Phoenix.Component

  alias Plug.Conn.Query
  use Gettext, backend: SafiraWeb.Gettext
  import SafiraWeb.CoreComponents

  attr :id, :string, required: true
  attr :items, :list, required: true
  attr :meta, Flop.Meta, required: true
  attr :row_id, :any, default: nil
  attr :params, :map, required: true
  attr :row_click, JS, default: nil

  slot :col do
    attr :label, :string, required: false
    attr :sortable, :boolean
    attr :field, :atom
  end

  slot :action do
    attr :label, :string, required: false
  end

  def table(assigns) do
    assigns =
      with %{items: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="relative overflow-x-auto">
      <div class="border rounded-lg bg-light border-lightShade dark:bg-dark dark:border-darkShade overflow-x-scroll scrollbar-hide">
        <table id={@id} class="w-full text-sm text-left text-dark dark:text-light">
          <thead class="text-xs border-b border-lightShade dark:border-darkShade font-normal uppercase text-darkMuted dark:text-lightMuted">
            <tr>
              <.header_column
                :for={col <- @col}
                label={col[:label]}
                sortable={col[:sortable]}
                params={@params}
                field={col[:field]}
                meta={@meta}
              />
              <.header_column :if={@action != []} class="text-right" />
            </tr>
          </thead>
          <tbody
            id={@id <> "-tbody"}
            phx-update={match?(%Phoenix.LiveView.LiveStream{}, @items) && "stream"}
          >
            <tr
              :for={item <- @items}
              id={@row_id && @row_id.(item)}
              class={[
                "border-b last:border-0 border-lightShade dark:border-darkShade",
                @row_click &&
                  "hover:cursor-pointer hover:bg-lightShade/20 dark:hover:bg-darkShade/20 transition-colors"
              ]}
              phx-click={@row_click && @row_click.(item)}
            >
              <td
                :for={col <- @col}
                scope="row"
                class="px-6 py-4 font-normal text-dark whitespace-nowrap dark:text-light"
              >
                <%= render_slot(col, item) %>
              </td>
              <td
                scope="row"
                class="px-6 py-4 relative w-14 font-norma text-dark whitespace-nowrap dark:text-light"
              >
                <div class="relative flex gap-4 text-right text-sm font-normal">
                  <span
                    :for={action <- @action}
                    class="dark:hover:text-lightShade/80 hover:text-darkShade/80 transition-colors"
                  >
                    <%= render_slot(action, item) %>
                  </span>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <.pagination :if={@meta.total_pages > 1} meta={@meta} params={@params} />
    </div>
    """
  end

  attr :label, :string, default: ""
  attr :sortable, :boolean, default: false
  attr :params, :map
  attr :field, :atom
  attr :meta, Flop.Meta
  attr :class, :string, default: ""

  defp header_column(assigns) do
    if assigns.sortable do
      assigns =
        Map.put(assigns, :order_direction, order_direction(assigns.meta.flop, assigns.field))

      ~H"""
      <th scope="col" class="px-6 py-3">
        <.link patch={next_order_query(@field, @meta.flop, @params)} class="flex items-center gap-x-4">
          <%= @label %>
          <.sort_arrow direction={@order_direction} />
        </.link>
      </th>
      """
    else
      ~H"""
      <th scope="col" class={"px-6 py-3 #{@class}"}>
        <%= @label %>
      </th>
      """
    end
  end

  attr :direction, :atom, required: true

  defp sort_arrow(assigns) do
    ~H"""
    <span class="transition-colors flex flex-col self-center h-full pb-1">
      <span
        role="img"
        aria-label="caret-up"
        class={[
          "h-[1em]",
          @direction in [:asc, :asc_nulls_first, :asc_nulls_last] && "text-dark dark:text-light"
        ]}
      >
        <.icon class="w-[1em] h-[1em]" name="hero-chevron-up" />
      </span>
      <span
        role="img"
        aria-label="caret-down"
        class={[
          "h-[1em]",
          @direction in [:desc, :desc_nulls_first, :desc_nulls_last] && "text-dark dark:text-light"
        ]}
      >
        <.icon class="w-[1em] h-[1em]" name="hero-chevron-down" />
      </span>
    </span>
    """
  end

  attr :meta, Flop.Meta, required: true
  attr :params, :map, required: true

  defp pagination(assigns) do
    ~H"""
    <nav
      class="flex items-center flex-column flex-wrap md:flex-row justify-between py-4"
      aria-label="Table navigation"
    >
      <span class="text-sm font-normal text-darkMuted dark:text-lightMuted mb-4 md:mb-0 block w-full md:inline md:w-auto">
        <%= gettext("Showing") %>
        <span class="font-semibold text-dark dark:text-light">
          <%= @meta.current_offset + 1 %>-<%= @meta.next_offset || @meta.total_count %>
        </span>
        <%= gettext("of") %>
        <span class="font-semibold text-dark dark:text-light">
          <%= @meta.total_count %>
        </span>
      </span>
      <ul class="inline-flex -space-x-px rtl:space-x-reverse text-sm h-8">
        <.pagination_button
          text={gettext("Previous")}
          left_corner={true}
          disabled={!@meta.has_previous_page?}
          page={@meta.previous_page}
          params={@params}
        />
        <%= if max(1, @meta.current_page - 2) != 1 do %>
          <.pagination_button page={1} params={@params} />
        <% end %>
        <%= for page <- max(1, @meta.current_page - 2)..max(min(@meta.total_pages, @meta.current_page + 2), 1) do %>
          <.pagination_button page={page} params={@params} is_current={@meta.current_page == page} />
        <% end %>
        <%= if min(@meta.total_pages, @meta.current_page + 2) != @meta.total_pages do %>
          <.pagination_button page={@meta.total_pages} params={@params} />
        <% end %>
        <.pagination_button
          text={gettext("Next")}
          right_corner={true}
          disabled={!@meta.has_next_page?}
          page={@meta.next_page}
          params={@params}
        />
      </ul>
    </nav>
    """
  end

  attr :text, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :left_corner, :boolean, default: false
  attr :right_corner, :boolean, default: false
  attr :is_current, :boolean, default: false
  attr :page, :integer
  attr :params, :map

  defp pagination_button(assigns) do
    if assigns.disabled do
      ~H"""
      <li>
        <p class={[
          "hover:cursor-default select-none flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 border border-gray-300 bg-gray-100 border-lightShade dark:border-darkShade dark:text-gray-400 dark:bg-dark",
          @right_corner && "rounded-e-lg",
          @left_corner && "rounded-s-lg"
        ]}>
          <%= if @text == "", do: @page, else: @text %>
        </p>
      </li>
      """
    else
      ~H"""
      <li>
        <.link
          patch={build_query("page", @page, @params)}
          class={[
            "flex select-none items-center justify-center px-3 h-8 ms-0 leading-tight border border-lightShade dark:bg-dark dark:border-darkShade dark:hover:bg-darkShade dark:hover:text-light transition-colors",
            @right_corner && "rounded-e-lg",
            @left_corner && "rounded-s-lg",
            !@is_current &&
              "text-gray-500 bg-white hover:bg-gray-100 hover:text-gray-700 dark:text-light",
            @is_current && "text-dark bg-gray-100 dark:text-light dark:bg-darkShade/20"
          ]}
        >
          <%= if @text == "", do: @page, else: @text %>
        </.link>
      </li>
      """
    end
  end

  defp build_query(key, value, params) do
    query = Map.put(params, key, value)

    "?#{Query.encode(query)}"
  end

  defp order_direction(%Flop{order_by: [field | _], order_directions: [direction | _]}, field) do
    direction
  end

  defp order_direction(%Flop{}, _), do: nil

  defp next_order_query(field, flop, params) do
    updated_flop =
      if order_direction(flop, field) == :desc do
        index = Enum.find_index(flop.order_by, &(&1 == field))

        %{
          flop
          | order_by: List.delete_at(flop.order_by, index),
            order_directions: List.delete_at(flop.order_directions, index)
        }
      else
        Flop.push_order(flop, field)
      end

    query =
      params
      |> Map.put("order_by", updated_flop.order_by)
      |> Map.put("order_directions", updated_flop.order_directions)

    "?#{Query.encode(query)}"
  end
end
