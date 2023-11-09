defmodule Mix.Tasks.Gift.All.Badges do
  @moduledoc """
  Task to gift all badges to an attendee
  """
  use Mix.Task

  def run(args) do
    if length(args) != 1 do
      Mix.shell().info("Needs to receive only an id.")
    else
      args |> List.first() |> create
    end
  end

  defp create(attendee_id) do
    Mix.Task.run("app.start")

    Safira.Contest.list_badges()
    |> Enum.map(
      &Safira.Contest.create_redeem(%{attendee_id: attendee_id, staff_id: 1, badge_id: &1.id})
    )
  end
end
