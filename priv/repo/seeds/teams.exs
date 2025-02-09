defmodule Safira.Repo.Seeds.Teams do
  alias Safira.{Repo, Teams}
  alias Safira.Teams.Team

  @teams [
    {"Main Organization", ["Alice", "Bob"]},
    {"Tech", ["Dave", "Eve", "Frank", "Grace", "Heidi"]},
    {"Marketing", ["Ivan", "Judy", "Mallory", "Niaj", "Olivia"]},
    {"Program", ["Peggy", "Sybil", "Trent", "Victor", "Walter"]},
    {"Sponsorships", ["Xander", "Yvonne", "Zara", "Aaron", "Betty"]},
    {"Logistics", ["Carol"]}
  ]

  def run do
    case Repo.all(Team) do
      [] ->
        seed_teams()

      _ ->
        Mix.shell().error("Found teams, aborting seeding teams.")
    end
  end

  defp seed_teams do
    Enum.with_index(@teams)
    |> Enum.each(&insert_team_with_members/1)
  end

  defp insert_team_with_members({{name, members}, id}) do
    team_seed = %{
      name: name,
      priority: id,
      id: id
    }

    case Teams.create_team(team_seed) do
      {:ok, team} ->
        Enum.each(members, &insert_team_member(&1, team.id))

      {:error, _changeset} ->
        Mix.shell().error("Failed to insert team: #{name}")
    end
  end

  defp insert_team_member(member, team_id) do
    attrs = %{
      name: member,
      team_id: team_id
    }

    case Teams.create_team_member(attrs) do
      {:ok, _member} ->
        nil
      {:error, _changeset} ->
        Mix.shell().error("Failed to insert team member: #{member}")
    end
  end
end

Safira.Repo.Seeds.Teams.run()
