defmodule Mix.Tasks.Export.Attendees.Entries do
  @moduledoc """
  Task to export the entries for the final draw to a CSV.

  Run it as mix export.attendees.entries data/entries.csv Aggregate
  to have one row per attendee (with the number of entries in it)
  Run it as mix export.attendees.entries data/entries.csv Separate to have
  one row per entry (this is needed to run the draw in random.org, for example)

  As this script writes to a file, you need to run it in your local machine pointing
  to the production database.
  """
  use Mix.Task
  alias Safira.Accounts

  def run(args) do
    Mix.Task.run("app.start")

    cond do
      length(args) != 2 ->
        Mix.shell().info(
          "Needs to receive a path to write the file to and whether to aggregate the entries"
        )

      args |> List.last() == "Aggregate" ->
        write_csv(List.first(args), :aggregate)

      args |> List.last() == "Separate" ->
        write_csv(List.first(args), :separate)

      true ->
        Mix.shell().info(~s(Second argument must be equal to "Aggregate" and "Separate"))
    end
  end

  defp write_csv(file, mode) do
    data =
      Accounts.list_active_attendees()
      |> Enum.map(fn at -> csv_io(at, mode) end)
      |> List.flatten()
      |> Enum.with_index()
      |> Enum.map(fn {entry, index} -> "#{index + 1},#{entry}" end)
      |> add_header(mode)
      |> Enum.intersperse("\n")
      |> List.flatten()

    File.write!(file, data)
  end

  defp csv_io(attendee, :separate) do
    Enum.to_list(1..attendee.entries)
    |> Enum.map(fn _x -> "#{attendee.name},#{attendee.nickname}" end)
  end

  defp csv_io(attendee, :aggregate) do
    if attendee.entries > 0 do
      [
        "#{attendee.name},#{attendee.nickname},#{attendee.entries}"
      ]
    else
      []
    end
  end

  defp add_header(list, :aggregate) do
    ["id,name,nickname,entries" | list]
  end

  defp add_header(list, :separate) do
    ["id,name,nickname" | list]
  end
end
