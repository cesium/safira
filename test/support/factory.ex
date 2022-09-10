defmodule Safira.Factory do
  use ExMachina.Ecto, repo: Safira.Repo
  use Safira.UserStrategy
  use Safira.AccountFactory
  use Safira.ContestFactory
  use Safira.PrizeStrategy
  use Safira.PrizeFactory
end
