defmodule Safira.Factory do
  use ExMachina.Ecto, repo: Safira.Repo
  use Safira.UserStrategy
  use Safira.AccountFactory
  # use Safira.UserFactory
  # use Safira.AttendeeFactory
  use Safira.BadgeFactory
  use Safira.RedeemFactory
  use Safira.PrizeStrategy
  use Safira.PrizeFactory
end
