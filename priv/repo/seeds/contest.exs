defmodule Safira.Repo.Seeds.Contest do
  @moduledoc false

  def run do
    seed_badges()
  end

  defp seed_badges do
    Mix.Tasks.Gen.Badges.run(["data/badges.csv"])
  end
end

Safira.Repo.Seeds.Contest.run()
