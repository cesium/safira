defmodule SafiraWeb.Backoffice.MinigamesLive.ScratchCardSymbols.FormComponent do
  @moduledoc false
  use SafiraWeb, :live_component

  alias Safira.Minigames
  alias Safira.Minigames.ScratchCardSymbol

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Scratch Card Symbols Table")}
        subtitle={gettext("Configures the symbols table for the scratch card minigame.")}
      >
        <div class="pt-8">
          <div class="flex flex-row justify-between items-center">
            <h2 class="font-semibold">{gettext("Symbols")}</h2>
            <.button phx-click={JS.push("add-symbol", target: @myself)}>
              <.icon name="hero-plus" class="w-5 h-5" />
            </.button>
          </div>
          <ul class="h-[45vh] overflow-y-scroll space-y-2 scrollbar-hide my-4 border-b border-lightShade dark:border-darkShade">
            <%= for {id, symbol, form} <- @symbols do %>
              <.live_component
                module={SafiraWeb.Backoffice.MinigamesLive.ScratchCardSymbols.SymbolRow}
                id={id}
                symbol={symbol}
                form={form}
                parent={@myself}
                parent_id={@id}
              />
            <% end %>
          </ul>
          <p :if={length(@symbols) < 3} class="text-slate-500 mb-4">
            <.icon name="hero-exclamation-triangle" class="text-warning-600 mr-1" />{gettext(
              "The scratch card needs at least 3 symbols to work."
            )}
          </p>
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
  def update(assigns, socket) do
    {symbol_saved, assigns} = Map.pop(assigns, :symbol_saved)
    {symbol_save_error, assigns} = Map.pop(assigns, :symbol_save_error)
    {symbol_validate, assigns} = Map.pop(assigns, :symbol_validate)

    socket = assign(socket, assigns)

    socket =
      case symbol_saved do
        {id, %ScratchCardSymbol{} = symbol} ->
          symbols =
            Enum.map(socket.assigns.symbols, fn
              {^id, _old_symbol, _form} ->
                {id, symbol, to_form(Minigames.change_scratch_card_symbol(symbol))}

              other ->
                other
            end)

          assign(socket, symbols: symbols)

        _ ->
          socket
      end

    socket =
      case symbol_save_error do
        {id, %Ecto.Changeset{} = changeset} ->
          symbols =
            update_symbol_form(socket.assigns.symbols, id, to_form(changeset, action: :validate))

          assign(socket, symbols: symbols)

        _ ->
          socket
      end

    socket =
      case symbol_validate do
        {id, symbol_params} ->
          symbols = socket.assigns.symbols
          symbol = get_symbol_data_by_id(symbols, id)
          changeset = Minigames.change_scratch_card_symbol(symbol, symbol_params)

          symbols = update_symbol_form(symbols, id, to_form(changeset, action: :validate))
          assign(socket, symbols: symbols)

        _ ->
          socket
      end

    {:ok, socket}
  end

  @impl true
  def mount(socket) do
    symbols =
      Minigames.list_scratch_card_symbols()
      |> Enum.map(fn symbol ->
        {Ecto.UUID.generate(), symbol, to_form(Minigames.change_scratch_card_symbol(symbol))}
      end)

    {:ok, socket |> assign(symbols: symbols)}
  end

  @impl true
  def handle_event("add-symbol", _, socket) do
    symbols = socket.assigns.symbols

    {:noreply,
     socket
     |> assign(
       :symbols,
       symbols ++
         [
           {Ecto.UUID.generate(), %ScratchCardSymbol{},
            to_form(Minigames.change_scratch_card_symbol(%ScratchCardSymbol{}))}
         ]
     )}
  end

  @impl true
  def handle_event("delete-symbol", %{"id" => id}, socket) do
    symbols = socket.assigns.symbols
    symbol = Enum.find(symbols, fn {symbol_id, _, _} -> symbol_id == id end) |> elem(1)

    if symbol.id != nil do
      Minigames.delete_scratch_card_symbol(symbol)
    end

    {:noreply,
     socket |> assign(symbols: Enum.reject(symbols, fn {symbol_id, _, _} -> symbol_id == id end))}
  end

  @impl true
  def handle_event("save", _params, socket) do
    symbols = socket.assigns.symbols

    {symbols, all_valid?} = validate_symbol_forms(symbols)

    if all_valid? do
      Enum.each(symbols, fn {id, symbol, form} ->
        Phoenix.LiveView.send_update(
          SafiraWeb.Backoffice.MinigamesLive.ScratchCardSymbols.SymbolRow,
          id: id,
          symbol: symbol,
          form: form,
          parent: socket.assigns.myself,
          save: true
        )
      end)

      {:noreply,
       socket
       |> assign(symbols: symbols)
       |> put_flash(:info, "Scratch card configuration changed successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:noreply, socket |> assign(symbols: symbols)}
    end
  end

  defp update_symbol_form(symbols, id, new_form) do
    Enum.map(symbols, fn
      {^id, symbol, _} -> {id, symbol, new_form}
      other -> other
    end)
  end

  defp get_symbol_data_by_id(symbols, id) do
    Enum.find(symbols, &(elem(&1, 0) == id)) |> elem(1)
  end

  defp forms_valid?(forms) do
    Enum.all?(forms, fn form -> form.source.valid? end)
  end

  defp validate_symbol_forms(symbols) do
    validated =
      Enum.map(symbols, fn {id, symbol, form} ->
        params = form.params || %{}
        changeset = Minigames.change_scratch_card_symbol(symbol, params)
        {id, symbol, to_form(changeset, action: :validate)}
      end)

    all_valid? = forms_valid?(Enum.map(validated, fn {_, _, form} -> form end))

    {validated, all_valid?}
  end
end
