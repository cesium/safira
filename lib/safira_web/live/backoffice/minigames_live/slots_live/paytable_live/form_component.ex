defmodule SafiraWeb.Backoffice.MinigamesLive.SlotsPaytable.FormComponent do
  @moduledoc false
  alias Safira.Minigames.SlotsPaytable
  use SafiraWeb, :live_component

  alias Safira.Contest
  alias Safira.Minigames
  alias Safira.Minigames.WheelDrop

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={gettext("Slots Paytable")} subtitle={gettext("Configures the slots paytable.")}>
        <:actions>
          <.link patch={~p"/dashboard/minigames/wheel/simulator"}>
            <.button>
              <.icon name="hero-play" class="w-5 h-5" />
            </.button>
          </.link>
        </:actions>
        <div class="pt-8">
          <div class="flex flex-row justify-between items-center">
            <h2 class="font-semibold"><%= gettext("Entries") %></h2>
            <.button phx-click={JS.push("add-entry", target: @myself)}>
              <.icon name="hero-plus" class="w-5 h-5" />
            </.button>
          </div>
          <ul class="h-[45vh] overflow-y-scroll scrollbar-hide mt-4 border-b-[1px] border-lightShade  dark:border-darkShade">
            <%= for {id, _drop, form} <- @entries do %>
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
                    <.field field={form[:multiplier]} type="number" wrapper_class="col-span-2" />
                    <.field field={form[:probability]} type="number" wrapper_class="col-span-2" />
                    <.link
                      phx-click={JS.push("delete-entry", value: %{id: id})}
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
    entries =
      Minigames.list_slots_paytables()
      |> Enum.map(fn entry ->
        {Ecto.UUID.generate(), entry, to_form(Minigames.change_slots_paytable(entry))}
      end)

    {:ok,
     socket
     |> assign(entries: entries)
     |> assign(nothing_probability: calculate_nothing_probability(entries))
     |> assign(prizes: Minigames.list_prizes())
     |> assign(badges: Contest.list_badges())}
  end

  @impl true
  def handle_event("add-entry", _, socket) do
    entries = socket.assigns.entries

    # Add a new drop to the list
    {:noreply,
     socket
     |> assign(
       :entries,
       entries ++
         [
           {Ecto.UUID.generate(), %SlotsPaytable{},
            to_form(Minigames.change_slots_paytable(%SlotsPaytable{}))}
         ]
     )}
  end

  @impl true
  def handle_event("delete-entry", %{"id" => id}, socket) do
    entries = socket.assigns.entries
    # Find the drop to delete in the drops list
    drop = Enum.find(entries, fn {drop_id, _, _} -> drop_id == id end) |> elem(1)

    # If the drop has an id, delete it from the database
    if drop.id != nil do
      Minigames.delete_slots_paytable(drop)
    end

    nothing_probability = calculate_nothing_probability(entries)

    # Remove the drop from the list
    {:noreply,
     socket
     |> assign(entries: Enum.reject(entries, fn {drop_id, _, _} -> drop_id == id end))
     |> assign(nothing_probability: nothing_probability)}
  end

  @impl true
  def handle_event("validate", drop_params, socket) do
    entries = socket.assigns.entries
    entry = get_entry_data_by_id(entries, drop_params["identifier"])
    changeset = Minigames.change_slots_paytable(entry, drop_params["slots_paytable"])

    # Update the form with the new changeset and the drop type if it changed
    entries =
      socket.assigns.entries
      |> update_drop_form(drop_params["identifier"], to_form(changeset, action: :validate))

    nothing_probability = calculate_nothing_probability(entries)

    {:noreply,
     socket
     |> assign(entries: entries)
     |> assign(nothing_probability: nothing_probability)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    drops = socket.assigns.entries

    # Find if all the changesets are valid
    valid_drops =
      forms_valid?(Enum.map(drops, fn {_, _, form} -> form end)) and
        calculate_nothing_probability(drops) >= 0

    IO.inspect(drops)
    IO.inspect(valid_drops)
    IO.inspect(forms_valid?(Enum.map(drops, fn {_, _, form} -> form end)))

    if valid_drops do
      # For each drop, update or create it
      Enum.each(drops, fn {_, drop, form} ->
        if drop.id != nil do
          Minigames.update_slots_paytable(drop, form.params)
        else
          Minigames.create_slots_paytable(form.params)
        end
      end)

      {:noreply,
       socket
       |> put_flash(:info, "Slots paytable changed successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:noreply, socket}
    end
  end

  defp update_drop_type_form_if_type_changed(drops, _id, _type), do: drops

  defp update_drop_form(entries, id, new_form) do
    Enum.map(entries, fn
      {^id, entry, _} -> {id, entry, new_form}
      other -> other
    end)
  end

  def get_entry_data_by_id(drops, id) do
    Enum.find(drops, &(elem(&1, 0) == id)) |> elem(1)
  end

  defp generate_options(values) do
    Enum.map(values, &{&1.name, &1.id})
  end

  defp calculate_nothing_probability(drops) do
    drops
    |> Enum.map(&elem(&1, 2))
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
      form.source.valid? and has_valid_values?(form)
    end)
  end

  defp has_valid_values?(form) do
    params_valid =
      not is_nil(form.params["multiplier"]) and not is_nil(form.params["probability"])

    data_valid = not is_nil(form.data.multiplier) and not is_nil(form.data.probability)

    params_valid or data_valid
  end
end
