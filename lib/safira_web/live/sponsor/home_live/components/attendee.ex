defmodule SafiraWeb.Sponsor.HomeLive.Components.Attendee do
  @moduledoc """
  Vault item component.
  """
  use SafiraWeb, :component

  import SafiraWeb.Helpers
  import SafiraWeb.Components.Avatar

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :handle, :string, required: true
  attr :image, :string, default: nil
  attr :cv, :string

  def attendee(assigns) do
    ~H"""
    <li id={@id} class="block py-4 md:px-4 text-center">
      <div class="px-4">
        <div class="m-auto w-fit">
          <.avatar size={:lg} handle={@handle} src={@image} />
        </div>
        <div class="flex flex-row gap-1.5 justify-center items-center mt-2">
          <p class="text-center text-sm line-clamp-2">
            {short_name(@name)}
          </p>
          <.link
            :if={not is_nil(@cv)}
            href={@cv}
            target="_blank"
            class="hover:text-accent underline text-sm shrink-0"
            title={gettext("Download CV")}
            aria-label={gettext("Download CV")}
          >
            <.icon name="hero-document-arrow-down" class="w-5 h-5 mb-0.5" />
          </.link>
        </div>
      </div>
    </li>
    """
  end
end
