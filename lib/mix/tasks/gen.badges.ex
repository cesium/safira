defmodule Mix.Tasks.Gen.Badges do
  @moduledoc """
  Task to generate badges
  """
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSV

  # Its waiting for an header or an empty line on the beggining of the file
  # format Coffee break;badge do lanche;2019-02-11;2019-02-12;/tmp/goraster.png

  def run(args) do
    if Enum.empty?(args) do
      Mix.shell().info("Needs to receive a file URL.")
    else
      args |> List.first() |> create
    end
  end

  defp create(path) do
    Mix.Task.run("app.start")

    path
    |> parse_csv()
    |> sequence()
    |> create_badges()
    |> insert_badge()
  end

  defp create_badges({create, update}) do
    {Safira.Contest.create_badges(create), update}
  end

  defp sequence(list) do
    create = Enum.map(list, fn value -> elem(value, 0) end)
    update = Enum.map(list, fn value -> elem(value, 1) end)
    {create, update}
  end

  defp insert_badge(transactions) do
    case Safira.Repo.transaction(elem(transactions, 0)) do
      {:ok, result} ->
        result
        |> Map.to_list()
        |> Enum.sort_by(&{elem(&1, 0)})
        |> Enum.zip(elem(transactions, 1))
        |> Enum.map(fn {a, b} ->
          Safira.Contest.update_badge(elem(a, 1), b)
        end)

      {:error, error} ->
        IO.puts(error)
    end
  end

  defp parse_csv(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(fn [
                     name,
                     description,
                     begin_time,
                     end_time,
                     begin_badge,
                     end_badge,
                     image_path,
                     type,
                     tokens,
                     counts_for_day
                   ] ->
      {:ok, begin_datetime, _} = DateTime.from_iso8601(begin_time)
      {:ok, end_datetime, _} = DateTime.from_iso8601(end_time)
      {:ok, begin_badge_datetime, _} = DateTime.from_iso8601(begin_badge)
      {:ok, end_badge_datetime, _} = DateTime.from_iso8601(end_badge)

      {
        %{
          name: name,
          description: description,
          begin: begin_datetime,
          end: end_datetime,
          begin_badge: begin_badge_datetime,
          end_badge: end_badge_datetime,
          type: String.to_integer(type),
          tokens: String.to_integer(tokens),
          counts_for_day: String.to_integer(counts_for_day) != 0
        },
        %{
          avatar: get_avatar(image_path)
        }
      }
    end)
  end

  defp get_avatar(nil), do: nil

  defp get_avatar(image_path) do
    %Plug.Upload{
      filename: String.split(image_path, "/") |> List.last(),
      path: image_path
    }
  end
end
