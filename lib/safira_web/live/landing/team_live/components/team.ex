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
      <h2 class="text-xl font-bold uppercase text-white mb-2 ml-2"><%= @team_name %></h2>
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3">
        <div :for={member <- @members} class="flex flex-col items-start">
          <img
            src={
              if member.image,
                do: Uploaders.Member.url({member.image, member}, :original, signed: true),
                else: "/images/image_team.png"
            }
            alt={"#{member.name}'s photo"}
            class="w-36 h-36 object-cover"
          />
          <p class="font-terminal text-lg text-white uppercase mb-8"><%= member.name %></p>
        </div>
      </div>
    </div>
    """
  end
end
