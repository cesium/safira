defmodule Safira.Repo.Seeds.Store do
  @moduledoc false

  def run do
    seed_redeemables()
  end

  defp seed_redeemables do
    Mix.Tasks.Gen.Redeemables.run(["data/redeemables.csv"])
  end
end

Safira.Repo.Seeds.Store.run()
