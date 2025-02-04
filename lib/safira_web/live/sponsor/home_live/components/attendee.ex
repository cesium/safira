defmodule SafiraWeb.Sponsor.HomeLive.Components.Attendee do
  @moduledoc """
  Vault item component.
  """
  use SafiraWeb, :component

  import SafiraWeb.Components.Avatar

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :image, :string, required: true

  def attendee(assigns) do
    ~H"""
    <li id={@id} class="flex flex-row p-4">
      <.link href={"/user/#{@user.handle}"} class="w-full h-full">
        <div class="px-4">
          <div class="m-auto w-fit">
            <.avatar size={:lg} handle={@user.handle} />
          </div>
          <p class="font-terminal text-center uppercase text-xl">
            <%= @user.name %>
          </p>
        </div>
      </.link>
    </li>
    """
  end
end
