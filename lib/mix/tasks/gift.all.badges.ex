defmodule Mix.Tasks.Gift.All.Badges do
  use Mix.Task

  def run(args) do
    cond do
      length(args) != 1 ->
        Mix.shell.info "Needs to receive only an id."
      true ->
        args |> List.first |> create
    end
  end

  defp create(attendee_id) do
    Mix.Task.run "app.start"

    Safira.Contest.list_badges 
    |> Enum.map(&(Safira.Contest.create_redeem(%{attendee_id: attendee_id, manager_id: 1, badge_id: &1.id})))
  end
end
