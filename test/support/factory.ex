defmodule Safira.Factory do
  use ExMachina.Ecto, repo: Safira.Repo

  use Safira.AccountsFactory
  use Safira.UserStrategy
  use Safira.ContestFactory
  use Safira.PrizeStrategy
  use Safira.RouletteFactory
end
