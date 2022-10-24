defmodule Mix.Tasks.Gift.Badge.Full.Participation do
  @moduledoc """
  Task to gift all badges to an attendee
  """
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest

  def run(args) do
    if Enum.empty?(args) do
      Mix.shell().info("Needs badge_id.")
    else
      create(args)
    end
  end

  defp create(badge_id) do
    Mix.Task.run("app.start")

    b1 = Contest.get_badge_name!("Dia 1")
    b2 = Contest.get_badge_name!("Dia 2")
    b3 = Contest.get_badge_name!("Dia 3")
    b4 = Contest.get_badge_name!("Dia 4")

    lb = [b1, b2, b3, b4]

    Enum.each(
      Accounts.list_active_attendees(),
      fn a -> gift_badge(badge_id, lb, a.id) end
    )
  end

  defp gift_badge(badge_id, list_badges, attendee_id) do
    give =
      Enum.map(
        list_badges,
        fn l -> !is_nil(Contest.get_keys_redeem(attendee_id, l.id)) end
      )
      |> Enum.reduce(fn x, acc -> x && acc end)

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
