defmodule Mix.Tasks.Govern.Staff do
  @moduledoc """
  Deprecated
  """
  use Mix.Task

  def run(args) do
    if length(args) != 1 do
      Mix.shell().info("Needs id")
    else
      args |> List.first() |> create
    end
  end

  defp create(id) do
    Mix.Task.run("app.start")

    Safira.Accounts.get_attendee!(id)
    |> Safira.Accounts.volunteer_update_attendee(%{volunteer: true})
  end
end
