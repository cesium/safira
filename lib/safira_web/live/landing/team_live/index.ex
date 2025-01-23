defmodule SafiraWeb.Landing.TeamLive.Index do
  use SafiraWeb, :landing_view

  alias Safira.Teams
  import SafiraWeb.Teamcomponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, teams: Teams.list_teams(preloads: [:team_members]))}
  end
end
