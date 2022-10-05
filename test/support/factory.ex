defmodule Safira.Factory do
  use ExMachina.Ecto, repo: Safira.Repo

  use Safira.UserStrategy
  use Safira.PrizeStrategy

  use Safira.AccountsFactory
  use Safira.ContestFactory
  use Safira.StoreFactory
  use Safira.RouletteFactory
  use Safira.InteractionFactory
end
