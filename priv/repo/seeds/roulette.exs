defmodule Safira.Repo.Seeds.Roulette do
  @moduledoc false

  def run do
    seed_prizes()
  end

  defp seed_prizes do
    Mix.Tasks.Gen.Prizes.run(["data/wheel.csv"])
  end
end

Safira.Repo.Seeds.Roulette.run()
