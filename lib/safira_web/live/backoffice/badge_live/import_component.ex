defmodule SafiraWeb.Backoffice.BadgeLive.ImportComponent do
  use SafiraWeb, :live_component

  alias NimbleCSV.RFC4180, as: CSV
  alias Safira.Contest

  import SafiraWeb.Components.Progress

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <.guide :if={!@status} />
        <form phx-change="files-selected" phx-target={@myself} class="py-4">
          <p :if={@status} class="text-center"><%= status_message(@status) %></p>
          <p :if={@status == :error} class="text-red-600"><%= @error_reason %></p>
          <div class={@status && "hidden"}>
            <.live_file_input upload={@uploads.dir} class="hidden" />
            <label for="dir">
              <div class="w-full h-48 transition-colors hover:cursor-pointer hover:bg-lightShade/30 dark:hover:bg-darkShade/20 border-2 border-dashed rounded-xl border-lightShade dark:border-darkShade">
                <article class="h-full">
                  <figure class="h-full flex items-center justify-center">
                    <div class="select-none flex flex-col gap-2 items-center text-lightMuted dark:text-darkMuted">
                      <.icon name="hero-folder" class="w-12 h-12" />
                      <p class="px-4 text-center"><%= gettext("Upload folder.") %></p>
                    </div>
                  </figure>
                </article>
              </div>
              <input id="dir" type="file" webkitdirectory={true} phx-hook="ZipUpload" class="hidden" />
            </label>
          </div>
          <div class="py-4">
            <%= for entry <- @uploads.dir.entries do %>
              <.progress progress={entry.progress} />
            <% end %>
          </div>
        </form>
      </.page>
    </div>
    """
  end

  defp guide(assigns) do
    ~H"""
    <div>
      <p class="mb-4">
        <.icon name="hero-exclamation-triangle" class="text-warning-600 mr-1" />
        <%= gettext("This functionality should not be used during the event.") %>
      </p>
      <p>
        <%= gettext("Uploaded folder should have this exact structure:") %>
      </p>
      <!-- Folder structure -->
      <div class="flex flex-col py-4 gap-4">
        <div class="flex flex-col">
          <div class="flex flex-row gap-2">
            <.icon name="hero-folder" />
          </div>
          <div class="ml-4">
            <div class="flex flex-row gap-2">
              <.icon name="hero-document" />
              <p>badges.csv</p>
            </div>
            <div class="flex flex-row gap-2">
              <.icon name="hero-folder" />
              <p>images</p>
            </div>
            <div class="ml-4">
              <div class="flex flex-row gap-2">
                <.icon name="hero-document" />
                <p>lucky_bastard.svg</p>
              </div>
              <div class="flex flex-row gap-2">
                <.icon name="hero-ellipsis-horizontal" />
              </div>
            </div>
          </div>
        </div>
        <!-- CSV structure -->
        <div class="w-full flex flex-col gap-2">
          <p>
            <%= gettext(
              "The badges file should be named badges.csv and have the following tabular structure:"
            ) %>
          </p>
          <table class="border border-collapse text-xs">
            <thead>
              <tr class="border font-normal">
                <th>name</th>
                <th>description</th>
                <th>begin</th>
                <th>end</th>
                <th>image</th>
                <th>category</th>
                <th>tokens</th>
                <th>counts_for_day</th>
              </tr>
            </thead>
            <tbody>
              <tr class="border text-center">
                <td class="border">Lucky Bastard</td>
                <td class="border">Spin the wheel!</td>
                <td class="border">2025-02-11 09:00</td>
                <td class="border">2025-02-14 18:00</td>
                <td class="border">lucky_bastard.svg</td>
                <td class="border">General</td>
                <td class="border">100</td>
                <td class="border">true</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(files: [], status: nil)
     |> allow_upload(:dir,
       accept: :any,
       max_entries: 1,
       auto_upload: true,
       max_file_size: 1_000_000_000,
       progress: &handle_progress/3
     )}
  end

  @impl true
  def handle_event("files-selected", _, socket) do
    {:noreply, assign(socket, status: :compressing)}
  end

  def handle_progress(:dir, entry, socket) do
    if entry.done? do
      temp_dir = System.tmp_dir!()

      [{dest, _paths}] =
        consume_uploaded_entries(socket, :dir, fn %{path: path}, _entry ->
          case :zip.list_dir(~c"#{path}") do
            {:ok, [{:zip_comment, []}, {:zip_file, first, _, _, _, _} | _]} ->
              dest_path = Path.join(temp_dir, Path.basename(to_string(first)))

              case :zip.unzip(~c"#{path}", cwd: ~c"#{temp_dir}") do
                {:ok, paths} -> {:ok, {dest_path, paths}}
                {:error, reason} -> {:error, reason}
              end

            {:error, reason} ->
              {:error, reason}
          end
        end)

      case import_badges(dest) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:success, "Finished importing badges.")
           |> push_navigate(to: ~p"/dashboard/badges")}

        {:error, reason} ->
          {:noreply, socket |> assign(status: :error) |> assign(error_reason: reason)}
      end
    else
      {:noreply, assign(socket, status: :uploading)}
    end
  end

  def import_badges(dest) do
    categories = Contest.list_badge_categories()
    badges_csv_path = Path.join(dest, "badges.csv")

    if File.exists?(badges_csv_path) do
      badges_csv_path
      |> File.stream!()
      |> CSV.parse_stream()
      |> Enum.reduce(categories, fn [_, _, _, _, _, category_name, _, _] = row, acc_categories ->
        {updated_categories, category} = find_or_create_category(category_name, acc_categories)
        import_badge(row, category, dest)
        updated_categories
      end)

      {:ok, "badges imported"}
    else
      {:error, "badges.csv not found"}
    end
  end

  def import_badge(row, category, dest) do
    [name, description, begin_time, end_time, image_name, _, tokens, counts_for_day] = row

    case Contest.create_badge(%{
           name: name,
           description: description,
           begin: Timex.parse!(begin_time, "{YYYY}-{0M}-{0D} {h24}:{m}"),
           end: Timex.parse!(end_time, "{YYYY}-{0M}-{0D} {h24}:{m}"),
           tokens: tokens,
           counts_for_day: string_to_bool(counts_for_day),
           category_id: category.id
         }) do
      {:ok, badge} ->
        case Contest.update_badge_image(badge, %{
               image: %Plug.Upload{
                 path: Path.join([dest, "images", image_name]),
                 content_type: "image/svg",
                 filename: image_name
               }
             }) do
          {:ok, _} -> :ok
          {:error, _} -> :error
        end

      {:error, _} ->
        :error
    end
  end

  defp find_or_create_category(category_name, categories) do
    case Enum.find(categories, fn c -> c.name == category_name end) do
      nil ->
        case Contest.create_badge_category(%{
               name: category_name,
               color: Contest.BadgeCategory.colors() |> Enum.random(),
               hidden: false
             }) do
          {:ok, new_category} ->
            {categories ++ [new_category], new_category}

          {:error, _} ->
            {categories, nil}
        end

      existing_category ->
        {categories, existing_category}
    end
  end

  defp status_message(status) do
    case status do
      :compressing -> gettext("Compressing data...")
      :uploading -> gettext("Uploading...")
      :error -> gettext("An error occurred:")
      nil -> nil
    end
  end
end
