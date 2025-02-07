defmodule SafiraWeb.Landing.TeamLive.Index do
  use SafiraWeb, :landing_view

  alias Safira.Teams
  import SafiraWeb.Teamcomponent

  on_mount {SafiraWeb.VerifyFeatureFlag, "team_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    teams = Teams.list_teams(preloads: [:team_members])

    sorted_teams =
      Enum.map(teams, fn team ->
        %{team | team_members: Enum.sort_by(team.team_members, & &1.name)}
      end)

    {:ok, assign(socket, teams: sorted_teams)}
  end
end
