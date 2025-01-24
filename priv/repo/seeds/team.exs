defmodule Safira.Repo.Seeds.Teams do
  alias Safira.{Teams, Repo}
  alias Safira.Teams.Team

  @teams [
    {"Organização", ["Alice", "Bob", "Charlie"]},
    {"Tech", ["Dave", "Eve", "Frank", "Grace", "Heidi"]},
    {"Marketing", ["Ivan", "Judy", "Mallory", "Niaj", "Olivia"]},
    {"Programa", ["Peggy", "Sybil", "Trent", "Victor", "Walter"]},
    {"Patrocínios", ["Xander", "Yvonne", "Zara", "Aaron", "Betty"]},
    {"Logística", ["Carol"]}
  ]

  def run do
    case Teams.list_teams(%{}) do
      [] ->
        seed_teams()
      _  ->
        Mix.shell().error("Found teams, aborting seeding teams.")
    end
  end

  def seed_teams do
    for {name, members} <- @teams do
      team_seed = %{
        name: name,
        members: members
      }

      changeset = Teams.change_team(%Team{}, team_seed)

      case Repo.insert(changeset) do
        {:ok, _team} ->
          :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert team: #{team_seed.name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end
end

Safira.Repo.Seeds.Teams.run()
