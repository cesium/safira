defmodule Mix.Tasks.Gift.All.Attendees.Badge do
  @moduledoc """
  Task to give a badge to all attendees
  """
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest
  alias Safira.Contest.Badge

  def run(args) do
    cond do
      length(args) != 1 ->
        Mix.shell().info("Needs to receive only an id.")

      true ->
        args |> List.first() |> String.to_integer() |> create
    end
  end

  defp create(badge_id) do
    Mix.Task.run("app.start")

    with _badge = %Badge{} <- Contest.get_badge!(badge_id) do
      Accounts.list_attendees()
      |> Enum.each(fn a ->
        Contest.create_redeem(%{
          attendee_id: a.id,
          manager_id: 1,
          badge_id: badge_id
        })
      end)
    end
  end
end
