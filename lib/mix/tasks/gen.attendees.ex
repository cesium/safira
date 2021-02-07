defmodule Mix.Tasks.Gen.Attendees do
  use Mix.Task

  def run(args) do
    cond do
      length(args) == 0 ->
        Mix.shell().info("Needs to receive a number greater than 0.")

      args |> List.first() |> String.to_integer() <= 0 ->
        Mix.shell().info("Needs to receive a number greater than 0.")

      true ->
        args |> List.first() |> String.to_integer() |> create
    end
  end

  defp create(n) do
    Mix.Task.run("app.start")

    Enum.each(1..n, fn _n ->
      created_attendee = Safira.Repo.insert!(%Safira.Accounts.Attendee{})
      IO.puts("Id: #{Map.get(created_attendee, :id)}")
      IO.puts("Association_code: #{Map.get(created_attendee, :discord_association_code)}")
    end)
  end
end
