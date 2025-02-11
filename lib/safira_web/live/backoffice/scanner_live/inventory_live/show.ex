defmodule SafiraWeb.Backoffice.ScannerLive.InventoryLive.Show do
  use SafiraWeb, :backoffice_view

  alias Safira.{Accounts, Inventory}

  import SafiraWeb.Components.Tabs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="-translate-y-4 sm:translate-y-0">
        <.tabs class="sm:hidden mb-4">
          <.link patch={~p"/dashboard/scanner"} class="w-full">
            <.tab class="gap-2">
              <.icon name="hero-check-badge" />
              <%= gettext("Badges") %>
            </.tab>
          </.link>
          <.link patch={~p"/dashboard/scanner/redeems"} class="w-full">
            <.tab active class="gap-2">
              <.icon name="hero-gift" />
              <%= gettext("Redeems") %>
            </.tab>
          </.link>
        </.tabs>
        <.page title={"#{@user.name}'s inventory"}>
          <ul id="items-list" class="space-y-4 py-8" phx-update="stream">
            <li
              :for={{id, item} <- @streams.items}
              id={id}
              class={"flex flex-row justify-between #{if item.redeemed_at do "opacity-50" end}"}
            >
              <div class="flex flex-row w-full">
                <figure class="w-32 h-32 bg-dark/5 dark:bg-light/5 rounded-xl flex-shrink-0">
                  <%= if get_item_image(item.type, get_item_data(item)) do %>
                    <img class="w-full p-4" src={get_item_image(item.type, get_item_data(item))} />
                  <% end %>
                </figure>
                <div class="py-4 px-4 w-auto">
                  <h1 class="font-semibold text-lg">
                    <%= get_item_data(item).name %>
                  </h1>
                  <p :if={!item.redeemed_at}>
                    <%= relative_datetime(item.inserted_at) %>
                  </p>
                  <p :if={item.redeemed_at} class="flex flex-row justify-center items-center">
                    <.icon name="hero-check" class="w-5 h-5 mr-1" />
                    <%= gettext("This item has been delivered.") %>
                  </p>
                </div>
              </div>
              <div :if={!item.redeemed_at} class="flex justify-center items-center">
                <span
                  phx-click="deliver"
                  class="w-8 h-8 flex items-center justify-center rounded-full border border-dark dark:border-light cursor-pointer hover:bg-dark/10 dark:hover:bg-light"
                  phx-value-id={item.id}
                >
                  <.icon name="hero-check" class="w-5 h-5" />
                </span>
              </div>
            </li>
          </ul>
        </.page>
      </div>
      <.modal
        :if={@selected_item != nil}
        id="deliver-item-modal"
        show
        wrapper_class="px-2"
        on_cancel={JS.push("cancel-deliver")}
      >
        <h1 class="font-semibold text-xl">
          <%= gettext("Deliver %{item_name}", item_name: get_item_data(@selected_item).name) %>
        </h1>
        <div class="flex flex-col gap-4 items-center mt-2">
          <p>
            <%= gettext(
              "Are you sure you want to mark this item as delivered? This action is not reversible."
            ) %>
          </p>

          <div class="flex flex-row w-full gap-2">
            <.button
              phx-click="cancel-deliver"
              class="w-full flex flex-row items-center justify-center"
            >
              <.icon name="hero-x-circle" class="w-5 h-5 mr-2" />
              <%= gettext("Cancel") %>
            </.button>
            <.button
              phx-click="confirm-deliver"
              class="w-full flex flex-row items-center justify-center"
            >
              <.icon name="hero-check-circle" class="w-5 h-5 mr-2" />
              <%= gettext("Deliver") %>
            </.button>
          </div>
        </div>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    attendee = Accounts.get_attendee!(id)
    user = Accounts.get_user!(attendee.user_id)

    {:noreply,
     socket
     |> assign(:current_page, :scanner)
     |> assign(:selected_item, nil)
     |> assign(:attendee, attendee)
     |> assign(:user, user)
     |> stream(:items, Inventory.list_attendee_items(id))}
  end

  @impl true
  def handle_event("deliver", %{"id" => id}, socket) do
    item = Inventory.get_item!(id)

    if item.redeemed_at || item.attendee_id != socket.assigns.attendee.id do
      {:noreply, socket}
    else
      {:noreply, assign(socket, :selected_item, item)}
    end
  end

  @impl true
  def handle_event("cancel-deliver", _params, socket) do
    {:noreply, assign(socket, :selected_item, nil)}
  end

  @impl true
  def handle_event("confirm-deliver", _params, socket) do
    case Inventory.update_item(socket.assigns.selected_item, %{redeemed_at: DateTime.utc_now()}) do
      {:ok, item} ->
        {:noreply,
         socket
         |> assign(:selected_item, nil)
         |> put_flash(:info, "Item has been successfully delivered.")
         |> stream_insert(:items, item)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "An error occurred while delivering the item.")
         |> assign(:selected_item, nil)}
    end
  end

  defp get_item_data(item) do
    case item.type do
      :product ->
        item.product

      :prize ->
        item.prize
    end
  end

  defp get_item_image(type, data) do
    case type do
      :product ->
        Uploaders.Product.url({data.image, data}, :original, signed: true)

      :prize ->
        Uploaders.Prize.url({data.image, data}, :original, signed: true)
    end
  end
end
