defmodule Mix.Tasks.Gift.Badge.Participation do
  @moduledoc """
  Task to give a badge to all attendees that completed at least a given number of days of the contest
  """
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest

  def run(args) do
    if length(args) != 2 do
      Mix.shell().info("Needs badge_id and number of days")
    else
      badge_id = String.to_integer(Enum.at(args, 0))
      days = String.to_integer(Enum.at(args, 1))

      create(badge_id, days)
    end
  end

  defp create(badge_id, days) do
    Mix.Task.run("app.start")

    b1 = Contest.get_badge_name!("Dia 1")
    b2 = Contest.get_badge_name!("Dia 2")
    b3 = Contest.get_badge_name!("Dia 3")
    b4 = Contest.get_badge_name!("Dia 4")

    lb = [b1, b2, b3, b4]

    Accounts.list_active_attendees()
    |> Enum.map(fn a -> gift_badge(badge_id, lb, a.id, days) end)
  end

  defp gift_badge(badge_id, list_badges, attendee_id, days) do
    give =
      Enum.map(
        list_badges,
        fn l -> !is_nil(Contest.get_keys_redeem(attendee_id, l.id)) end
      )
      |> Enum.filter(fn x -> x end)
      |> Enum.count()
      |> then(fn x -> x >= days end)

    if give do
      Contest.create_redeem(
        %{
          attendee_id: attendee_id,
          manager_id: 1,
          badge_id: badge_id
        },
        :admin
      )
    end
  end
end
