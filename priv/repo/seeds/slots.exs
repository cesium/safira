defmodule Safira.Repo.Seeds.Slots do
  alias Mix.Tasks.Gen.Payouts

  def run do
    seed_payouts()
  end

  defp seed_payouts do
    Payouts.run(["data/slots.csv"])
  end
end

Safira.Repo.Seeds.Slots.run()
