defmodule Safira.Factory do
  use ExMachina.Ecto, repo: Safira.Repo
  use Safira.UserStrategy
  use Safira.UserFactory
  use Safira.AttendeeFactory
  use Safira.BadgeFactory
  use Safira.RedeemFactory
end
