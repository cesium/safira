defmodule SafiraWeb.Components.ImageUploader do
  use SafiraWeb, :component

  attr :upload, :any, required: true
  attr :class, :string, default: ""
  attr :image, :string, default: nil

  def image_uploader(assigns) do
    ~H"""
    <.live_file_input upload={@upload} class="hidden" />
    <section
      phx-drop-target={@upload.ref}
      class={"transition-colors hover:cursor-pointer hover:bg-lightShade/30 dark:hover:bg-darkShade/20 border-2 border-dashed rounded-xl border-lightShade dark:border-darkShade #{@class}"}
      onclick={"document.getElementById('#{@upload.ref}').click()"}
    >
      <%= if @upload.entries == [] do %>
        <article class="h-full">
          <figure class="h-full flex items-center justify-center">
            <%= if @image do %>
              <img class="p-4" src={@image} />
            <% else %>
              <div class="select-none flex flex-col gap-2 items-center text-lightMuted dark:text-darkMuted">
                <.icon name="hero-photo" class="w-12 h-12" />
                <p><%= gettext("Upload a file or drag and drop") %></p>
              </div>
            <% end %>
          </figure>
        </article>
      <% end %>
      <%= for entry <- @upload.entries do %>
        <article class="h-full">
          <figure class="h-full flex items-center justify-center">
            <.live_img_preview class="p-4" entry={entry} />
          </figure>
          <%= for err <- upload_errors(@upload, entry) do %>
            <p class="alert alert-danger"><%= Phoenix.Naming.humanize(err) %></p>
          <% end %>
        </article>
      <% end %>
      <%= for err <- upload_errors(@upload) do %>
        <p class="alert alert-danger"><%= Phoenix.Naming.humanize(err) %></p>
      <% end %>
    </section>
    """
  end
end
