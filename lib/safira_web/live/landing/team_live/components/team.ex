defmodule SafiraWeb.Teamcomponent do
  @moduledoc """
  Team component.
  """
  use SafiraWeb, :component

  attr :team_name, :string, required: true
  attr :members, :list, required: true

  def team(assigns) do
    ~H"""
    <div class="text-left my-8">
      <h2 class="text-2xl font-bold uppercase text-white mb-6"><%= @team_name %></h2>
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
        <div :for={member <- @members} class="flex flex-col items-center">
          <img
            src={Uploaders.Member.url({member.image, member}, :original, signed: true)}
            alt={"#{member.name}'s photo"}
            class="w-36 h-36 object-cover"
          />
          <p class="mt-2 text-lg font-semibold text-white uppercase"><%= member.name %></p>
        </div>
      </div>
    </div>
    """
  end
end
