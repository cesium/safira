defmodule Safira.Factory do
  @moduledoc """
  A factory to facilitate testing and building all structs
  """
  use ExMachina.Ecto, repo: Safira.Repo

  use Safira.UserStrategy
  use Safira.PrizeStrategy

  use Safira.AccountsFactory
  use Safira.ContestFactory
  use Safira.StoreFactory
  use Safira.RouletteFactory
  use Safira.InteractionFactory
end
