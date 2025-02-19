defmodule SafiraWeb.PrizeLive.MinigamesLive.Daily.FormComponent do
  @moduledoc false
  use SafiraWeb, :live_component

  alias Safira.Contest
  alias Safira.Contest.DailyPrize
  alias Safira.Minigames

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={gettext("Daily Prizes")} subtitle={gettext("Configures the daily prizes.")}>
        <div class="pt-8">
          <div class="flex flex-row justify-between items-center">
            <h2 class="font-semibold"><%= gettext("Daily Prizes") %></h2>
            <.button phx-click={JS.push("add-prize", target: @myself)}>
              <.icon name="hero-plus" class="w-5 h-5" />
            </.button>
          </div>
          <ul class="h-[45vh] overflow-y-scroll scrollbar-hide mt-4 border-b-[1px] border-lightShade  dark:border-darkShade">
            <%= for {id, _daily_prize, form} <- @daily_prizes do %>
              <li class="border-b-[1px] last:border-b-0 border-lightShade dark:border-darkShade">
                <.simple_form
                  id={id}
                  for={form}
                  phx-change="validate"
                  phx-target={@myself}
                  class="!mt-0"
                >
                  <div class="grid space-x-2 grid-cols-10 pl-1">
                    <.field type="hidden" name="identifier" value={id} required />
                    <.field
                      field={form[:prize_id]}
                      wrapper_class="col-span-3"
                      type="select"
                      options={generate_options(@prizes)}
                      required
                    />
                    <.field
                      field={form[:place]}
                      wrapper_class="col-span-3"
                      type="select"
                      options={[1, 2, 3]}
                    />
                    <.field field={form[:date]} wrapper_class="col-span-3" type="date" required />
                    <.link
                      phx-click={JS.push("delete-prize", value: %{id: id})}
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
            Save Daily Prizes
          </.button>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    # Load the daily prizes
    daily_prizes =
      Contest.list_daily_prizes()
      |> Enum.map(fn p ->
        {Ecto.UUID.generate(), p, to_form(Contest.change_daily_prize(p))}
      end)

    {:ok,
     socket
     |> assign(daily_prizes: daily_prizes)
     |> assign(prizes: Minigames.list_prizes())}
  end

  @impl true
  def handle_event("add-prize", _, socket) do
    daily_prizes = socket.assigns.daily_prizes

    # Add a new drop to the list
    {:noreply,
     socket
     |> assign(
       :daily_prizes,
       [
         {Ecto.UUID.generate(), %DailyPrize{}, to_form(Contest.change_daily_prize(%DailyPrize{}))}
       ] ++
         daily_prizes
     )}
  end

  @impl true
  def handle_event("delete-prize", %{"id" => id}, socket) do
    daily_prizes = socket.assigns.daily_prizes
    # Find the daily prize to delete in the daily prizes list
    daily_prize = Enum.find(daily_prizes, fn {dp_id, _, _} -> dp_id == id end) |> elem(1)

    # If the daily prize has an id, delete it from the database
    if daily_prize.id != nil do
      Contest.delete_daily_prize(daily_prize)
    end

    # Remove the daily prize from the list
    {:noreply,
     socket
     |> assign(daily_prizes: Enum.reject(daily_prizes, fn {dp_id, _, _} -> dp_id == id end))}
  end

  @impl true
  def handle_event("validate", dp_params, socket) do
    daily_prizes = socket.assigns.daily_prizes
    daily_prize = get_daily_prize_data_by_id(daily_prizes, dp_params["identifier"])
    changeset = Contest.change_daily_prize(daily_prize, dp_params["daily_prize"])

    # Update the form with the new changeset and the drop type if it changed
    daily_prizes =
      socket.assigns.daily_prizes
      |> update_daily_prize_form(dp_params["identifier"], to_form(changeset, action: :validate))

    {:noreply,
     socket
     |> assign(daily_prizes: daily_prizes)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    daily_prizes = socket.assigns.daily_prizes

    # Find if all the changesets are valid
    valid_daily_prizes =
      forms_valid?(Enum.map(daily_prizes, fn {_, _, form} -> form end))

    if valid_daily_prizes do
      # For each daily_prize, update or create it
      Enum.each(daily_prizes, fn {_, dp, form} ->
        if dp.id != nil do
          Contest.update_daily_prize(dp, form.params)
        else
          Contest.create_daily_prize(form.params)
        end
      end)

      {:noreply,
       socket
       |> put_flash(:info, "Daily prizes changed successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:noreply, socket}
    end
  end

  defp update_daily_prize_form(daily_prizes, id, new_form) do
    Enum.map(daily_prizes, fn
      {^id, dp, _} -> {id, dp, new_form}
      other -> other
    end)
  end

  def get_daily_prize_data_by_id(drops, id) do
    Enum.find(drops, &(elem(&1, 0) == id)) |> elem(1)
  end

  defp generate_options(values) do
    Enum.map(values, &{&1.name, &1.id})
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
