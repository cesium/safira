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
      <h2 class="text-lg font-terminal uppercase text-white mb-2 font-bold"><%= @team_name %></h2>
      <div class="grid grid-cols-3 gap-8">
        <div :for={member <- @members} class="flex flex-col items-start">
          <img
            src={
              if member.image,
                do: Uploaders.Member.url({member.image, member}, :original, signed: true),
                else: "/images/team/placeholder.png"
            }
            alt={"#{member.name}'s photo"}
            width="210"
            height="210"
          />
          <p class="font-terminal text-md text-white uppercase mb-8 font-bold"><%= member.name %></p>
        </div>
      </div>
    </div>
    """
  end
end
