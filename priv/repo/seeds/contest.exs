defmodule Safira.Repo.Seeds.Contest do
  @moduledoc false

  alias Mix.Tasks.Gen.Badges
  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.Badge
  alias Safira.Repo

  @redeem_probability 0.05

  def run do
    seed_badges()
    seed_redeems()
  end

  defp seed_badges do
    Badges.run(["data/badges/badges.csv"])
  end

  defp seed_redeems do
    attendees = Repo.all(Attendee)
    badges = Repo.all(Badge)

    attendee_count = Enum.count(attendees)
    badge_count = Enum.count(badges)
    number_redeems = round(attendee_count * badge_count * @redeem_probability)

    redeems = for at <- attendees, b <- badges, do: %{
      attendee_id: at.id,
      badge_id: b.id
    }

    redeems
    |> Enum.take_random(number_redeems)
    |> Enum.each(&insert_redeem/1)
  end

  defp insert_redeem(redeem) do
    redeem
    |> Contest.create_redeem(:admin)
  end
end

Safira.Repo.Seeds.Contest.run()
