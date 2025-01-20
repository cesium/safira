defmodule SafiraWeb.Landing.TeamLive.Index do
  use SafiraWeb, :live_view

  alias Safira.Teams
  import SafiraWeb.Teamcomponent

  @impl true
  def mount(_params, _session, socket) do
    teams = Teams.list_teams()

    teams_with_members =
      Enum.map(teams, fn team ->
        members = Teams.list_team_members(team.id)

        %{
          name: team.name,
          members:
            Enum.map(members, fn member ->
              %{
                photo_url: Map.get(member, :photo_url, "/images/image_team.png"),
                name: member.name
              }
            end)
        }
      end)

    {:ok, assign(socket, teams: teams_with_members)}
  end
end
