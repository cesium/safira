defmodule SafiraWeb.Backoffice.MinigamesLive.ScratchCardSymbols.SymbolRow do
  @moduledoc false
  use SafiraWeb, :live_component

  alias Safira.Minigames
  alias Safira.Uploaders.ScratchCardSymbols

  import SafiraWeb.Components.ImageUploader
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <li class="border-b pb-2 last:border-b-0 border-lightShade dark:border-darkShade">
      <.simple_form id={@id} for={@form} phx-change="validate" phx-target={@myself} class="mt-0!">
        <div class="flex gap-8 pl-1">
          <div class="flex flex-col gap-1">
            <.image_uploader
              class="size-20 border-2 border-dashed"
              upload={@uploads[@upload_name]}
              image={ScratchCardSymbols.url({@symbol.image, @symbol}, :original, signed: true)}
              icon="hero-squares-plus"
            />
            <%= for {msg, opts} <- @form[:image].errors do %>
              <p class="safira-form-field-error">{translate_error({msg, opts})}</p>
            <% end %>
          </div>

          <.field
            field={@form[:name]}
            id={"name-#{@id}"}
            type="text"
            wrapper_class="col-span-1 mb-0!"
          />

          <div class="flex-1 flex items-center justify-end">
            <.link
              phx-click={JS.push("delete-symbol", value: %{id: @id}, target: @parent)}
              data-confirm="Are you sure?"
              class="content-center px-3"
            >
              <.icon name="hero-trash" class="w-5 h-5" />
            </.link>
          </div>
        </div>
      </.simple_form>
    </li>
    """
  end

  @impl true
  def mount(socket) do
    # uploaders require diffent names
    upload_name = "symbol-image-#{socket.assigns.myself}"

    {:ok,
     socket
     |> assign(:upload_name, upload_name)
     |> allow_upload(upload_name,
       accept: ScratchCardSymbols.extension_whitelist(),
       auto_upload: true,
       max_entries: 1
     )}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    socket =
      if Map.get(assigns, :save, false) do
        socket
        |> save_symbol()
        |> assign(:save, false)
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"scratch_card_symbol" => symbol_params}, socket) do
    Phoenix.LiveView.send_update(
      SafiraWeb.Backoffice.MinigamesLive.ScratchCardSymbols.FormComponent,
      id: socket.assigns.parent_id,
      symbol_validate: {socket.assigns.id, symbol_params}
    )

    {:noreply, socket}
  end

  defp save_symbol(socket) do
    symbol = socket.assigns.symbol
    form = socket.assigns.form
    params = form.params || %{}

    if upload_in_progress?(socket) do
      changeset =
        symbol
        |> Minigames.change_scratch_card_symbol(params)
        |> Ecto.Changeset.add_error(:image, "upload in progress")

      notify_save_error(socket, changeset)
      socket
    else
      save_with_image_validation(symbol, params, socket)
    end
  end

  defp save_with_image_validation(symbol, params, socket) do
    if image_missing?(symbol, socket) do
      changeset =
        symbol
        |> Minigames.change_scratch_card_symbol(params)
        |> Ecto.Changeset.add_error(:image, "can't be blank")

      notify_save_error(socket, changeset)
      socket
    else
      persist_symbol(symbol, params, socket)
    end
  end

  defp persist_symbol(symbol, params, socket) do
    result =
      if symbol.id != nil do
        Minigames.update_scratch_card_symbol(symbol, params)
      else
        Minigames.create_scratch_card_symbol(params)
      end

    case result do
      {:ok, saved_symbol} ->
        consume_image_data(saved_symbol, socket)
        notify_save_success(socket, saved_symbol)
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        notify_save_error(socket, changeset)
        socket
    end
  end

  defp upload_in_progress?(socket) do
    {_done, in_progress} = uploaded_entries(socket, upload_name(socket))
    in_progress != []
  end

  defp image_missing?(symbol, socket) do
    symbol.image == nil and upload_entries(socket) == []
  end

  defp consume_image_data(symbol, socket) do
    consume_uploaded_entries(socket, upload_name(socket), fn %{path: path}, entry ->
      Minigames.update_scratch_card_symbol_image(symbol, %{
        "image" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, _symbol}] ->
        {:ok, symbol}

      _errors ->
        {:ok, symbol}
    end
  end

  defp notify_save_success(socket, saved_symbol) do
    Phoenix.LiveView.send_update(
      SafiraWeb.Backoffice.MinigamesLive.ScratchCardSymbols.FormComponent,
      id: socket.assigns.parent_id,
      symbol_saved: {socket.assigns.id, saved_symbol}
    )
  end

  defp notify_save_error(socket, changeset) do
    Phoenix.LiveView.send_update(
      SafiraWeb.Backoffice.MinigamesLive.ScratchCardSymbols.FormComponent,
      id: socket.assigns.parent_id,
      symbol_save_error: {socket.assigns.id, changeset}
    )
  end

  defp upload_name(socket), do: socket.assigns.upload_name

  defp upload_entries(socket) do
    socket.assigns.uploads
    |> Map.get(upload_name(socket), %{entries: []})
    |> Map.get(:entries, [])
  end
end
