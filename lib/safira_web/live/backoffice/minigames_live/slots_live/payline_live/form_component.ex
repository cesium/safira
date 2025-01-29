defmodule SafiraWeb.Backoffice.MinigamesLive.SlotsPayline.FormComponent do
  @moduledoc false
  alias Safira.Minigames.SlotsPayline
  use SafiraWeb, :live_component

  alias Safira.Contest
  alias Safira.Minigames

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
                    <.field field={form[:position_0]} wrapper_class="col-span-1" type="number" />
                    <.field field={form[:position_1]} wrapper_class="col-span-1" type="number" />
                    <.field field={form[:position_2]} wrapper_class="col-span-1" type="number" />
                    <.field field={form[:paytable_id]} type="select" wrapper_class="col-span-2" options={generate_options(@paytables)} />
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
      Minigames.list_slots_paylines()
      |> Enum.map(fn entry ->
        {Ecto.UUID.generate(), entry,
         to_form(Minigames.change_slots_payline(entry))}
      end)

    {:ok,
     socket
     |> assign(entries: entries)
     |> assign(nothing_probability: 0)
     |> assign(paytables: Minigames.list_slots_paytables())
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
           {Ecto.UUID.generate(), %SlotsPayline{},
            to_form(Minigames.change_slots_payline(%SlotsPayline{}))}
         ]
     )}
  end

  @impl true
  def handle_event("delete-entry", %{"id" => id}, socket) do
    entries = socket.assigns.entries
    # Find the drop to delete in the drops list
    drop = Enum.find(entries, fn {drop_id, _, _} -> drop_id == id end) |> elem(2)

    # If the drop has an id, delete it from the database
    if drop.id != nil do
      Minigames.delete_wheel_drop(drop)
    end

    # Remove the drop from the list
    {:noreply,
     socket |> assign(entries: Enum.reject(entries, fn {drop_id, _, _} -> drop_id == id end))}
  end

  @impl true
  def handle_event("validate", drop_params, socket) do
    entries = socket.assigns.entries
    entry = get_drop_data_by_id(entries, drop_params["identifier"])
    changeset = Minigames.change_slots_payline(entry, drop_params["slots_payline"])

    # Update the form with the new changeset and the drop type if it changed
    entries =
      socket.assigns.entries
      |> update_drop_form(drop_params["identifier"], to_form(changeset, action: :validate))

    {:noreply,
     socket
     |> assign(entries: entries)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    entries = socket.assigns.entries

    # Find if all the changesets are valid
    valid_drops =
      forms_valid?(Enum.map(entries, fn {_, _, form} -> form end))

    if valid_drops do
      # For each drop, update or create it
      Enum.each(entries, fn {_, drop, form} ->
        if drop.id != nil do
          Minigames.update_slots_payline(drop, form.params)
        else
          Minigames.create_slots_payline(form.params)
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

  defp update_drop_type_form_if_type_changed(drops, id, type) when type not in [nil, ""] do
    Enum.map(drops, fn
      {^id, _, drop, form} -> {id, String.to_atom(type), drop, form}
      other -> other
    end)
  end

  defp update_drop_type_form_if_type_changed(drops, _id, _type), do: drops

  defp update_drop_form(entries, id, new_form) do
    Enum.map(entries, fn
      {^id, entry, _} -> {id, entry, new_form}
      other -> other
    end)
  end

  def get_drop_data_by_id(drops, id) do
    Enum.find(drops, &(elem(&1, 0) == id)) |> elem(1)
  end

  defp generate_options(values) do
    Enum.map(values, &{&1.multiplier, &1.id})
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
      form.source.valid?
    end)
  end
end
