defmodule SafiraWeb.Sponsor.HomeLive.Components.Attendee do
  @moduledoc """
  Vault item component.
  """
  use SafiraWeb, :component

  alias Safira.Accounts.User

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
          <p class="font-terminal text-center uppercase text-xl">
            <%= @name %>
          </p>
        </div>
      </.link>
      <.link :if={not is_nil(@cv)} href={@cv} target="_blank" class="hover:text-accent underline text-sm">
          <%= gettext("CV") %>
      </.link>
    </li>
    """
  end
end
