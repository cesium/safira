defmodule SafiraWeb.Backoffice.MinigamesLive.ReelIcons.FormComponent do
  @moduledoc false
  alias Safira.Minigames.SlotsReelIcon
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms
  import SafiraWeb.Components.ImageUploader

  alias Safira.Minigames

  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Reel Icons Configuration")}
        subtitle={gettext("Configures slots reel icons.")}
      >
        <div class="mt-8">
          <.simple_form
            id="slots-reels-config-form"
            for={@form}
            phx-submit="save"
            phx-change="validate"
            phx-target={@myself}
          >
            <%!-- <div class="w-full pb-6">
              <.field_label>Number of icons</.field_label>
              <.input
                field={@form[:number_of_icons]}
                name="number_of_icons"
                type="number"
                min="1"
                value={@number_of_icons}
                phx-debounce="blur"
              />
            </div> --%>
            <div class="w-full pb-2">
              <.field_label>Upload Images</.field_label>
              <.image_uploader
                class="size-36 border-2 border-dashed"
                upload={@uploads.images}
                preview_disabled
                icon="hero-squares-plus"
              />
              <div class="mt-4 flex gap-4 overflow-x-auto p-2 border rounded-md">
                <%= for entry <- @uploads.images.entries do %>
                  <div class="relative group flex-shrink-0 bg-dark rounded-lg">
                    <.live_img_preview entry={entry} class="size-32 object-cover rounded-lg" />
                    <div class="absolute inset-0 flex items-center justify-center bg-black bg-opacity-50 opacity-0 group-hover:opacity-100">
                      <button
                        type="button"
                        class="text-white"
                        phx-click="cancel-upload"
                        phx-value-ref={entry.ref}
                        phx-target={@myself}
                      >
                        &times;
                      </button>
                    </div>
                    <%= for err <- upload_errors(@uploads.images, entry) do %>
                      <div class="mt-1 text-red-500 text-sm"><%= err %></div>
                    <% end %>
                  </div>
                <% end %>
                <%= if Enum.empty?(@uploads.images.entries) do %>
                  <div class="w-full h-32 rounded-lg flex items-center justify-center">
                    <span class="text-gray-400">No images uploaded</span>
                  </div>
                <% end %>
                <%!--                 
                <%= for i <- length(@uploads.images.entries)..(@number_of_icons - 1) do %>
                  <div class="size-32 border border-gray-300 rounded-lg flex items-center justify-center">
                    <span class="text-gray-400">Empty slot <%= i + 1 %></span>
                  </div>
                <% end %> --%>
              </div>
            </div>
            <div>
              <h3 class="font-semibold">
                <%= gettext("Number of icons: %{num_icons}",
                  num_icons: length(@uploads.images.entries)
                ) %>
              </h3>
              <p class="text-slate-500">
                <.icon name="hero-exclamation-triangle" class="text-warning-600 mr-1" /><%= gettext(
                  "For optimal icon placement the number of icons should be 9 and each icon should be a square image."
                ) %>
              </p>
            </div>
            <div class="flex justify-end">
              <.button phx-disable-with="Saving..."><%= gettext("Save Configuration") %></.button>
            </div>
          </.simple_form>
        </div>
      </.page>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:reel, %SlotsReelIcon{})
     |> allow_upload(:images,
       accept: Uploaders.SlotsReelIcon.extension_whitelist(),
       max_entries: 15
     )
     |> assign(form: to_form(%{}))}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Minigames.change_slots_reel_icon(socket.assigns.reel))
     end)}
  end

  def handle_event("validate", %{"number_of_icons" => number_of_icons}, socket) do
    number = max(String.to_integer(number_of_icons), 1)
    changeset = Minigames.change_slots_reel_icon(socket.assigns.reel, %{number_of_icons: number})

    {:noreply,
     socket
     |> assign(:number_of_icons, number)
     |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("validate", params, socket) do
    changeset = Minigames.change_slots_reel_icon(socket.assigns.reel, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  # Update save handler to use new consume_image_data
  def handle_event("save", _params, socket) do
    case consume_image_data(socket) do
      {:ok, _results} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reels created successfully")
         |> push_patch(to: ~p"/dashboard/minigames/slots")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  defp consume_image_data(socket) do
    existing_reels = Minigames.list_slots_reel_icons()

    Ecto.Multi.new()
    |> delete_existing_reels(existing_reels)
    |> create_new_reels(socket)
    |> Safira.Repo.transaction()
    |> handle_transaction_result()
  end

  defp delete_existing_reels(multi, reels) do
    Enum.reduce(reels, multi, fn reel, multi ->
      Ecto.Multi.delete(multi, {:delete_reel, reel.id}, reel)
    end)
  end

  defp create_new_reels(multi, socket) do
    Ecto.Multi.run(multi, :create_reels, fn _repo, _changes ->
      results =
        socket.assigns.uploads.images.entries
        |> Enum.with_index()
        |> Enum.map(fn {entry, index} ->
          create_reel_with_image(socket, entry, index)
        end)
        |> Enum.map(fn
          # Extract successful results
          {:ok, result} -> result
          error -> error
        end)

      if Enum.all?(results, &is_struct(&1, Safira.Minigames.SlotsReelIcon)) do
        {:ok, results}
      else
        {:error, "Failed to create some reels"}
      end
    end)
  end

  defp create_reel_with_image(socket, entry, index) do
    consume_uploaded_entry(socket, entry, fn %{path: path} ->
      Minigames.create_slots_reel_icon(%{
        "reel_0_index" => index,
        "reel_1_index" => index,
        "reel_2_index" => index
      })
      |> case do
        {:ok, reel} ->
          Minigames.update_slots_reel_icon_image(reel, %{
            "image" => %Plug.Upload{
              content_type: entry.client_type,
              filename: entry.client_name,
              path: path
            }
          })

        error ->
          error
      end
    end)
  end

  defp handle_transaction_result(transaction_result) do
    case transaction_result do
      {:ok, %{create_reels: results}} ->
        {:ok, results}

      {:error, _failed_operation, error, _changes} ->
        {:error, "Failed to update reels: #{inspect(error)}"}
    end
  end
end
