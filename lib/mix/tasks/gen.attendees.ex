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
      uuid = UUID.uuid4()
      cond do
        is_nil Safira.Repo.get_by(Safira.Accounts.Attendee, uuid: uuid) ->
          Safira.Repo.insert!(%Safira.Accounts.Attendee{:uuid => uuid})
      end
    end
  end
end
