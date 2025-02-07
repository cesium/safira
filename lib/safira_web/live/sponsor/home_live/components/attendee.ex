defmodule SafiraWeb.Sponsor.HomeLive.Components.Attendee do
  @moduledoc """
  Vault item component.
  """
  use SafiraWeb, :component

  import SafiraWeb.Components.Avatar

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :handle, :string, required: true
  attr :image, :string, required: true
  attr :cv, :string

  def attendee(assigns) do
    ~H"""
    <li id={@id} class="block p-4 text-center">
      <.link href={"/user/#{@handle}"} class="w-full h-full">
        <div class="px-4">
          <div class="m-auto w-fit">
            <.avatar size={:lg} handle={@handle} />
          </div>
          <p class="text-center text-sm mt-2">
            <%= @name %>
          </p>
        </div>
      </.link>
      <.link
        :if={not is_nil(@cv)}
        href={@cv}
        target="_blank"
        class="hover:text-accent underline text-sm"
      >
        <%= gettext("CV") %>
      </.link>
    </li>
    """
  end
end
