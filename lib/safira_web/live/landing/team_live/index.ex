defmodule SafiraWeb.Landing.TeamLive.Index do
  use SafiraWeb, :live_view

  import SafiraWeb.Teamcomponent
  alias Safira.Event

  @impl true
  def mount(_params, _session, socket) do
    members = [
      %{photo_url: "/images/icons/image_team.png", name: "Dário Guimarães"},
      %{photo_url: "/images/icons/image_team.png", name: "Enzo Vieira"},
      %{photo_url: "/images/icons/image_team.png", name: "João Lobo"},
      %{photo_url: "/images/icons/image_team.png", name: "Rui Lopes"},
      %{photo_url: "/images/icons/image_team.png", name: "Tiago Bacelar"}
    ]

    {:ok, assign(socket, team_name: "Tech", members: members)}
  end
end
