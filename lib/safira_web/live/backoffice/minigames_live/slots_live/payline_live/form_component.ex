defmodule SafiraWeb.Backoffice.MinigamesLive.SlotsPayline.FormComponent do
  @moduledoc false
  alias Safira.Minigames.SlotsPayline
  use SafiraWeb, :live_component

  alias Safira.Minigames

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={gettext("Slots Paytable")} subtitle={gettext("Configures the slots paytable.")}>
        <div class="pt-8">
          <div class="flex flex-row justify-between items-center">
            <h2 class="font-semibold">{gettext("Entries")}</h2>
            <.button phx-click="add-entry" phx-target={@myself}>
              <.icon name="hero-plus" class="w-5 h-5" />
            </.button>
          </div>
          <ul class="h-[45vh] overflow-y-scroll scrollbar-hide mt-4 border-b-[1px] border-lightShade  dark:border-darkShade">
            <%= for {id, _entry, form} <- @entries do %>
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
                    <.field
                      field={form[:position_0]}
                      wrapper_class="col-span-1"
                      type="select"
                      options={generate_position_options(@slots_reel_icons, 0)}
                    />
                    <.field
                      field={form[:position_1]}
                      wrapper_class="col-span-1"
                      type="select"
                      options={generate_position_options(@slots_reel_icons, 1)}
                    />
                    <.field
                      field={form[:position_2]}
                      wrapper_class="col-span-1"
                      type="select"
                      options={generate_position_options(@slots_reel_icons, 2)}
                    />
                    <.field
                      field={form[:paytable_id]}
                      type="select"
                      wrapper_class="col-span-2"
                      options={generate_options_multiplier(@paytables)}
                    />
                    <.link
                      phx-click="delete-entry"
                      phx-value-id={id}
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
    # Load the slot paylines entries
    entries =
      Minigames.list_slots_paylines()
      |> Enum.map(fn entry ->
        {Ecto.UUID.generate(), entry, to_form(Minigames.change_slots_payline(entry))}
      end)

    slots_reel_icons = Minigames.list_slots_reel_icons()

    {:ok,
     socket
     |> assign(entries: entries)
     |> assign(paytables: Minigames.list_slots_paytables())
     |> assign(slots_reel_icons: slots_reel_icons)}
  end

  @impl true
  def handle_event("add-entry", _, socket) do
    entries = socket.assigns.entries
    default_paytable = List.first(socket.assigns.paytables)
    default_paytable_id = if default_paytable != nil, do: default_paytable.id, else: nil

    {:noreply,
     socket
     |> assign(
       :entries,
       entries ++
         [
           {Ecto.UUID.generate(), %SlotsPayline{paytable_id: default_paytable_id},
            to_form(
              Minigames.change_slots_payline(%SlotsPayline{paytable_id: default_paytable_id})
            )}
         ]
     )}
  end

  @impl true
  def handle_event("delete-entry", %{"id" => id}, socket) do
    entries = socket.assigns.entries
    # Find the entry to delete in the entries list
    entry = Enum.find(entries, fn {entry_id, _, _} -> entry_id == id end) |> elem(1)

    # If the entry has an id, delete it from the database
    if entry.id != nil do
      Minigames.delete_slots_payline(entry)
    end

    # Remove the entry from the list
    {:noreply,
     socket |> assign(entries: Enum.reject(entries, fn {entry_id, _, _} -> entry_id == id end))}
  end

  @impl true
  def handle_event("validate", entry_params, socket) do
    entries = socket.assigns.entries
    entry = get_entry_data_by_id(entries, entry_params["identifier"])
    changeset = Minigames.change_slots_payline(entry, entry_params["slots_payline"])

    # Update the form with the new changeset and the entry type if it changed
    entries =
      socket.assigns.entries
      |> update_entry_form(entry_params["identifier"], to_form(changeset, action: :validate))

    {:noreply,
     socket
     |> assign(entries: entries)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    entries = socket.assigns.entries

    # Find if all the changesets are valid
    valid_entries =
      forms_valid?(Enum.map(entries, fn {_, _, form} -> form end))

    if valid_entries do
      # For each entry, update or create it
      Enum.each(entries, fn {_, entry, form} ->
        if entry.id != nil do
          Minigames.update_slots_payline(entry, form.params)
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

  defp update_entry_form(entries, id, new_form) do
    Enum.map(entries, fn
      {^id, entry, _} -> {id, entry, new_form}
      other -> other
    end)
  end

  def get_entry_data_by_id(entries, id) do
    Enum.find(entries, &(elem(&1, 0) == id)) |> elem(1)
  end

  defp generate_options_multiplier(values) do
    Enum.map(values, &{&1.multiplier, &1.id})
  end

  defp generate_position_options(slots_icons, reel_index) do
    visible_count = Minigames.count_visible_slots_reel_icons(slots_icons)[reel_index]

    visible_count_array =
      if visible_count == nil do
        []
      else
        Enum.map(0..(visible_count - 1), fn pos -> {Integer.to_string(pos), pos} end)
      end

    [{"Any", nil}] ++ visible_count_array
  end

  defp forms_valid?(forms) do
    Enum.all?(forms, fn form ->
      form.source.valid?
    end)
  end
end
