defmodule Mix.Tasks.Govern.Staff do
  use Mix.Task

  def run(args) do
    cond do
      length(args) != 1 ->
        Mix.shell().info("Needs id")

      true ->
        args |> List.first() |> create
    end
  end

  defp create(id) do
    Mix.Task.run("app.start")

    Safira.Accounts.get_attendee!(id)
    |> Safira.Accounts.volunteer_update_attendee(%{volunteer: true})
  end
end
