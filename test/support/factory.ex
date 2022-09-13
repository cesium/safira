defmodule Safira.Factory do
  use ExMachina.Ecto, repo: Safira.Repo
  use Safira.UserStrategy
  use Safira.AccountsFactory
  use Safira.ContestFactory
  use Safira.PrizeStrategy
  use Safira.PrizeFactory
  use Safira.StoreFactory
end
