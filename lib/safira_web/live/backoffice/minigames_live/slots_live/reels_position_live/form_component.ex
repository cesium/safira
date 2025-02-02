defmodule SafiraWeb.Backoffice.MinigamesLive.ReelsPosition.FormComponent do
  @moduledoc false
  alias Safira.Minigames.SlotsReelIcon
  use SafiraWeb, :live_component

  alias Safira.Minigames

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Reels Position Configuration")}
        subtitle={gettext("Configures slots reels.")}
      >
        <div class="mt-8">
          <div class="flex flex-row gap-10 mx-auto my-2 justify-center">
            <div
              :for={i <- 0..2}
              id={"reel-#{i}"}
              class="flex flex-col border-2 rounded-md max-w-36 max-h-72 overflow-scroll p-2 scrollbar-hide"
              phx-hook="Sorting"
            >
              <div
                :for={reel <- @slots_icons_per_column[i]}
                id={"reel-#{i}-#{reel.id}"}
                class="relative group"
              >
                <img
                  src={Uploaders.SlotsReelIcon.url({reel.image, reel}, :original, signed: true)}
                  alt="Icon"
                  class="size-20 bg-primary"
                />
                <div class={[
                  "handle absolute inset-0 flex items-center justify-center bg-white bg-opacity-50 opacity-0 group-hover:opacity-100",
                  !@visibility[i][reel.id] && "opacity-100"
                ]}>
                  <button
                    type="button"
                    class="text-black"
                    phx-value-reel-icon={reel.id}
                    phx-value-reel={"reel-#{i}"}
                    phx-click="toggle-reel"
                    phx-target={@myself}
                  >
                    <.icon name={if @visibility[i][reel.id], do: "hero-eye", else: "hero-eye-slash"} />
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div>
            <%= for i <- 0..2 do %>
              <p class={
                count_visible_icons(@visibility[i]) != count_visible_icons(@visibility[0]) &&
                  "text-red-600"
              }>
                <span class="font-semibold">Reel <%= i %>:</span> <%= count_visible_icons(
                  @visibility[i]
                ) %> visible icons
              </p>
            <% end %>
            <p class="text-slate-500 mt-4">
              <.icon name="hero-exclamation-triangle" class="text-warning-500 mr-1" /><%= gettext(
                "For optimal icon placement the number of icons should be 9."
              ) %>
            </p>
            <p class="text-slate-500">
              <.icon name="hero-information-circle" class="text-blue-500 mr-1" /><%= gettext(
                "Drag and drop the icons to change their order."
              ) %>
            </p>
          </div>
          <div class="flex justify-end">
            <.button
              phx-click="save"
              phx-target={@myself}
              phx-disable-with="Saving..."
              disabled={not all_reels_match?(@visibility)}
            >
              <%= gettext("Save Configuration") %>
            </.button>
          </div>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    slots_reel_icons = Minigames.list_slots_reel_icons()

    reel_order = %{
      "reel-0" => initialize_reel_order(slots_reel_icons, :reel_0_index),
      "reel-1" => initialize_reel_order(slots_reel_icons, :reel_1_index),
      "reel-2" => initialize_reel_order(slots_reel_icons, :reel_2_index)
    }

    visibility = %{
      0 =>
        Enum.reduce(slots_reel_icons, %{}, fn icon, acc ->
          Map.put(acc, icon.id, Map.get(icon, :reel_0_index) != -1)
        end),
      1 =>
        Enum.reduce(slots_reel_icons, %{}, fn icon, acc ->
          Map.put(acc, icon.id, Map.get(icon, :reel_1_index) != -1)
        end),
      2 =>
        Enum.reduce(slots_reel_icons, %{}, fn icon, acc ->
          Map.put(acc, icon.id, Map.get(icon, :reel_2_index) != -1)
        end)
    }

    {:ok,
     socket
     |> assign(:slots_reel_icons, slots_reel_icons)
     |> assign(:slots_icons_per_column, sort_reels_for_column(slots_reel_icons))
     |> assign(:reel, %SlotsReelIcon{})
     |> assign(:reel_order, reel_order)
     |> assign(:visibility, visibility)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("update-sorting", %{"ids" => ids}, socket) do
    reel_order =
      Enum.reduce(ids, socket.assigns.reel_order, fn id, acc ->
        [_reel, reel_index, _reel_id] = String.split(id, "-", parts: 3)

        Map.update!(acc, "reel-#{reel_index}", fn _order ->
          Enum.with_index(ids)
          |> Enum.reduce(%{}, fn {id, index}, order_acc ->
            [_reel, _reel_index, reel_id] = String.split(id, "-", parts: 3)
            Map.put(order_acc, reel_id, index)
          end)
        end)
      end)

    slots_icons_per_column =
      update_slots_icons_per_column(socket.assigns.slots_reel_icons, reel_order)

    {:noreply,
     socket
     |> assign(:reel_order, reel_order)
     |> assign(:slots_icons_per_column, slots_icons_per_column)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    case save_reel_order(socket) do
      {:ok, _results} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reel configuration saved successfully")
         |> push_patch(to: ~p"/dashboard/minigames/slots")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)}
    end
  end

  @impl true
  def handle_event("toggle-reel", %{"reel-icon" => reel_icon, "reel" => reel}, socket) do
    [_, reel_num] = String.split(reel, "-", parts: 2)
    reel_num = String.to_integer(reel_num)

    visibility =
      Map.update!(socket.assigns.visibility, reel_num, fn reel_map ->
        Map.update!(reel_map, reel_icon, &(!&1))
      end)

    {:noreply, socket |> assign(:visibility, visibility)}
  end

  defp save_reel_order(socket) do
    reel_order = socket.assigns.reel_order
    visibility = socket.assigns.visibility

    Ecto.Multi.new()
    |> update_reel_order(reel_order["reel-0"], visibility[0], :reel_0_index)
    |> update_reel_order(reel_order["reel-1"], visibility[1], :reel_1_index)
    |> update_reel_order(reel_order["reel-2"], visibility[2], :reel_2_index)
    |> Safira.Repo.transaction()
    |> handle_transaction_result()
  end

  defp update_reel_order(multi, reel_order, visibility, reel_index_field) do
    visible_reel_order = Enum.filter(reel_order, fn {id, _index} -> visibility[id] end)
    hidden_reel_order = Enum.filter(reel_order, fn {id, _index} -> not visibility[id] end)

    recalculated_reel_order =
      visible_reel_order
      |> Enum.sort_by(fn {_id, index} -> index end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {{id, _}, index}, acc -> Map.put(acc, id, index) end)

    final_reel_order =
      Enum.reduce(hidden_reel_order, recalculated_reel_order, fn {id, _}, acc ->
        Map.put(acc, id, -1)
      end)

    Enum.reduce(final_reel_order, multi, fn {id, index}, multi ->
      case Minigames.get_slots_reel_icon!(id) do
        nil ->
          multi

        reel ->
          Ecto.Multi.update(
            multi,
            {:update_reel, reel_index_field, id},
            Minigames.change_slots_reel_icon(reel, %{reel_index_field => index})
          )
      end
    end)
  end

  defp handle_transaction_result(transaction_result) do
    case transaction_result do
      {:ok, results} ->
        {:ok, results}

      {:error, _failed_operation, error, _changes} ->
        {:error, "Failed to update reels: #{inspect(error)}"}
    end
  end

  defp sort_reels_for_column(reels) do
    %{
      0 => sort_reels_for_column_by_index(reels, 0),
      1 => sort_reels_for_column_by_index(reels, 1),
      2 => sort_reels_for_column_by_index(reels, 2)
    }
  end

  defp sort_reels_for_column_by_index(reels, column_index) do
    index_field = String.to_existing_atom("reel_#{column_index}_index")

    {hidden, visible} = Enum.split_with(reels, &(Map.get(&1, index_field) == -1))

    visible =
      visible
      |> Enum.sort_by(&Map.get(&1, index_field))

    visible ++ hidden
  end

  defp initialize_reel_order(slots_reel_icons, index_field) do
    {hidden, visible} = Enum.split_with(slots_reel_icons, &(Map.get(&1, index_field) == -1))

    visible_order =
      visible
      |> Enum.sort_by(&Map.get(&1, index_field))
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {icon, index}, acc -> Map.put(acc, to_string(icon.id), index) end)

    hidden_order =
      hidden
      |> Enum.with_index(Enum.count(visible_order))
      |> Enum.reduce(%{}, fn {icon, index}, acc -> Map.put(acc, to_string(icon.id), index) end)

    Map.merge(visible_order, hidden_order)
  end

  defp update_slots_icons_per_column(slots_reel_icons, reel_order) do
    %{
      0 => update_slots_icons_per_column_by_index(slots_reel_icons, reel_order["reel-0"]),
      1 => update_slots_icons_per_column_by_index(slots_reel_icons, reel_order["reel-1"]),
      2 => update_slots_icons_per_column_by_index(slots_reel_icons, reel_order["reel-2"])
    }
  end

  defp update_slots_icons_per_column_by_index(slots_reel_icons, reel_order) do
    slots_reel_icons
    |> Enum.filter(fn icon -> Map.has_key?(reel_order, icon.id) end)
    |> Enum.sort_by(fn icon -> reel_order[icon.id] end)
  end

  defp count_visible_icons(visibility) do
    Enum.count(visibility, fn {_id, visible} -> visible end)
  end

  defp all_reels_match?(visibility) do
    counts = Enum.map(0..2, fn i -> count_visible_icons(visibility[i]) end)
    Enum.all?(counts, fn count -> count == List.first(counts) end)
  end
end
