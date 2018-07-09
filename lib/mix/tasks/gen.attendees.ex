defmodule Mix.Tasks.Gen.Attendees do
  use Mix.Task

  def run(args) do
    cond do
      length(args) == 0 ->
        Mix.shell.info "Needs receive a number greater than 0."
      args |> List.first |> String.to_integer <= 0 ->
        Mix.shell.info "Needs receive a number greater than 0."
      true ->
        args |> List.first |> String.to_integer |> create
    end
  end

  defp create(n) do
    Mix.Task.run "app.start"

    Enum.each 1..n, fn(_n) ->
      uuid = Ecto.UUID.generate()
      cond do
        is_nil Safira.Repo.get(Safira.Accounts.Attendee, uuid) ->
          Safira.Repo.insert!(%Safira.Accounts.Attendee{:id => uuid})
      end
    end
  end
end
