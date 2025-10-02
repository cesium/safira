defmodule SafiraWeb.Backoffice.MinigamesLive.WheelDrops.FormComponent do
  @moduledoc false
  alias Safira.Minigames.WheelDrop
  use SafiraWeb, :live_component

  alias Safira.Contest
  alias Safira.Minigames
  alias Safira.Minigames.WheelDrop

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Lucky Wheel Drops Table")}
        subtitle={gettext("Configures the drop loot table for the lucky wheel minigame.")}
      >
        <:actions>
          <.link patch={~p"/dashboard/minigames/wheel/simulator"}>
            <.button>
              <.icon name="hero-play" class="w-5 h-5" />
            </.button>
          </.link>
        </:actions>
        <div class="pt-8">
          <div class="flex flex-row justify-between items-center">
            <h2 class="font-semibold">{gettext("Drops")}</h2>
            <.button phx-click={JS.push("add-drop", target: @myself)}>
              <.icon name="hero-plus" class="w-5 h-5" />
            </.button>
          </div>
          <ul class="h-[45vh] overflow-y-scroll scrollbar-hide mt-4 border-b-[1px] border-lightShade  dark:border-darkShade">
            <%= for {id, type, _drop, form} <- @drops do %>
              <li class="border-b-[1px] last:border-b-0 border-lightShade dark:border-darkShade">
                <.simple_form
                  id={id}
                  for={form}
                  phx-change="validate"
                  phx-target={@myself}
                  class="!mt-0"
                >
                  <.field type="hidden" name="identifier" value={id} />
                  <div class="grid space-x-2 grid-cols-9 pl-1">
                    <%= if type == :nil do %>
                      <.field
                        wrapper_class="col-span-4"
                        value={nil}
                        placeholder="Select drop type"
                        options={[
                          {"Select a drop type", nil},
                          {"Prize", :prize},
                          {"Badge", :badge},
                          {"Tokens", :tokens},
                          {"Entries", :entries}
                        ]}
                        name="set_type"
                        label="Type"
                        type="select"
                      />
                    <% else %>
                      <%= if type == :prize do %>
                        <.field
                          field={form[:prize_id]}
                          wrapper_class="col-span-4"
                          type="select"
                          options={generate_options(@prizes)}
                        />
                      <% end %>
                      <%= if type == :badge do %>
                        <.field
                          field={form[:badge_id]}
                          wrapper_class="col-span-4"
                          type="select"
                          options={generate_options(@badges)}
                        />
                      <% end %>
                      <%= if type == :tokens do %>
                        <.field field={form[:tokens]} wrapper_class="col-span-4" type="number" />
                      <% end %>
                      <%= if type == :entries do %>
                        <.field field={form[:entries]} wrapper_class="col-span-4" type="number" />
                      <% end %>
                    <% end %>
                    <.field field={form[:max_per_attendee]} type="number" wrapper_class="col-span-2" />
                    <.field field={form[:probability]} type="number" wrapper_class="col-span-2" />
                    <.link
                      phx-click={JS.push("delete-drop", value: %{id: id})}
                      data-confirm="Are you sure?"
                      phx-target={@myself}
                      class="content-center px-3"
                    >
                      <.icon name="hero-trash" class="w-5 h-5" />
                    </.link>
                  </div>
                </.simple_form>
              </li>
            <% end %>
          </ul>
          <!-- Probability of nothing -->
          <div class="w-full flex flex-row-reverse pt-8">
            <.field
              class="col-span-2"
              type="number"
              name="probability"
              label="Remaining probability"
              value={@nothing_probability}
              readonly
              disabled
            />
          </div>
        </div>
        <div class="w-full flex flex-row-reverse">
          <.button phx-click="save" phx-target={@myself} phx-disable-with="Saving...">
            Save Configuration
          </.button>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    # Load the wheel drops
    drops =
      Minigames.list_wheel_drops()
      |> Enum.map(fn drop ->
        {Ecto.UUID.generate(), Minigames.get_wheel_drop_type(drop), drop,
         to_form(Minigames.change_wheel_drop(drop))}
      end)

    {:ok,
     socket
     |> assign(drops: drops)
     |> assign(nothing_probability: calculate_nothing_probability(drops))
     |> assign(prizes: Minigames.list_prizes())
     |> assign(badges: Contest.list_badges())}
  end

  @impl true
  def handle_event("add-drop", _, socket) do
    drops = socket.assigns.drops

    # Add a new drop to the list
    {:noreply,
     socket
     |> assign(
       :drops,
       drops ++
         [
           {Ecto.UUID.generate(), nil, %WheelDrop{},
            to_form(Minigames.change_wheel_drop(%WheelDrop{}))}
         ]
     )}
  end

  @impl true
  def handle_event("delete-drop", %{"id" => id}, socket) do
    drops = socket.assigns.drops
    # Find the drop to delete in the drops list
    drop = Enum.find(drops, fn {drop_id, _, _, _} -> drop_id == id end) |> elem(2)

    # If the drop has an id, delete it from the database
    if drop.id != nil do
      Minigames.delete_wheel_drop(drop)
    end

    # Remove the drop from the list
    {:noreply,
     socket |> assign(drops: Enum.reject(drops, fn {drop_id, _, _, _} -> drop_id == id end))}
  end

  @impl true
  def handle_event("validate", drop_params, socket) do
    drops = socket.assigns.drops
    drop = get_drop_data_by_id(drops, drop_params["identifier"])
    changeset = Minigames.change_wheel_drop(drop, drop_params["wheel_drop"])

    # Update the form with the new changeset and the drop type if it changed
    drops =
      socket.assigns.drops
      |> update_drop_type_form_if_type_changed(drop_params["identifier"], drop_params["set_type"])
      |> update_drop_form(drop_params["identifier"], to_form(changeset, action: :validate))

    nothing_probability = calculate_nothing_probability(drops)

    {:noreply,
     socket
     |> assign(drops: drops)
     |> assign(nothing_probability: nothing_probability)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    drops = socket.assigns.drops

    # Find if all the changesets are valid
    valid_drops =
      forms_valid?(Enum.map(drops, fn {_, _, _, form} -> form end)) and
        calculate_nothing_probability(drops) >= 0

    if valid_drops do
      # For each drop, update or create it
      Enum.each(drops, fn {_, _, drop, form} ->
        if drop.id != nil do
          Minigames.update_wheel_drop(drop, form.params)
        else
          Minigames.create_wheel_drop(form.params)
        end
      end)

      {:noreply,
       socket
       |> put_flash(:info, "Wheel configuration changed successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:noreply, socket}
    end
  end

  defp update_drop_type_form_if_type_changed(drops, id, type) when type not in [nil, ""] do
    Enum.map(drops, fn
      {^id, _, drop, form} -> {id, String.to_atom(type), drop, form}
      other -> other
    end)
  end

  defp update_drop_type_form_if_type_changed(drops, _id, _type), do: drops

  defp update_drop_form(drops, id, new_form) do
    Enum.map(drops, fn
      {^id, drop_type, drop, _} -> {id, drop_type, drop, new_form}
      other -> other
    end)
  end

  def get_drop_data_by_id(drops, id) do
    Enum.find(drops, &(elem(&1, 0) == id)) |> elem(2)
  end

  defp generate_options(values) do
    Enum.map(values, &{&1.name, &1.id})
  end

  defp calculate_nothing_probability(drops) do
    drops
    |> Enum.map(&elem(&1, 3))
    |> Enum.reduce(1.0, fn form, acc ->
      from_data =
        if form.data.probability != nil do
          Float.to_string(form.data.probability)
        else
          "0"
        end

      acc - (Map.get(form.params, "probability", from_data) |> try_parse_float())
    end)
    |> Float.round(12)
  end

  defp try_parse_float(value) do
    case Float.parse(value) do
      {float, _} -> float
      _ -> 0.0
    end
  end

  defp forms_valid?(forms) do
    Enum.all?(forms, fn form ->
      form.source.valid? and
        (form.params["prize_id"] || form.data.prize_id || form.params["badge_id"] ||
           form.data.badge_id || form.params["tokens"] || form.data.tokens ||
           form.params["entries"] || form.data.entries)
    end)
  end
end
