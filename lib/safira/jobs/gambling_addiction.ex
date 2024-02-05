defmodule Safira.Jobs.GamblingAddiction do
  @moduledoc """
  Job to gift the gambling addiction badge to all eligible attendees.
  Eligible attendees are those that spun the wheel and played at the slots at least once.

  Receives the badge_id.
  """
  import Ecto.Query, warn: false

  alias Safira.Accounts.{Attendee, Company}
  alias Safira.Contest
  alias Safira.Contest.{Badge, Redeem}
  alias Safira.Repo
  alias Safira.Roulette.AttendeePrize
  alias Safira.Slots.AttendeePayout

  @spec run(integer()) :: :ok
  def run(badge_id) do
    list_eligible_attendees()
    |> Enum.each(&create_redeem(&1.id, badge_id))
  end

  defp list_eligible_attendees do
    Attendee
    |> join(:inner, [a], ap in AttendeePrize, on: a.id == ap.attendee_id)
    |> join(:inner, [a, ap], sp in AttendeePayout, on: a.id == sp.attendee_id)
    |> where([a, ap, sp], not is_nil(ap.id) and not is_nil(sp.id))
    |> select([a], a)
    |> Repo.all()
  end

  defp create_redeem(attendee_id, badge_id) do
    Contest.create_redeem(
      %{
        attendee_id: attendee_id,
        staff_id: 1,
        badge_id: badge_id
      },
      :admin
    )
  end
end
