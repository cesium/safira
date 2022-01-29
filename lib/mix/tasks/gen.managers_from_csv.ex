defmodule Mix.Tasks.Gen.ManagersFromCsv do
  use Mix.Task
  alias Ecto.Multi
  alias Safira.Repo
  alias Safira.Auth
  alias Safira.Accounts.User
  alias Safira.Accounts.Attendee

  alias NimbleCSV.RFC4180, as: CSV

  @shortdoc "Generates the attendees from a CSV and sends emails to finish registration"

  @moduledoc """
  This task is waiting for a CSV where the 3rd collumn is name,
   4th collumn is last name and 5th collumn is email
  and a flag ("Local"/"Remote") indicating if the file is local or remote

  ex:
  mix gen.users_from_csv "assets/participantes_sei_exemplo.csv" "Local"
  mix gen.users_from_csv "https://sample.url.participantes_sei_exemplo.csv" "Remote"
  """

  def run(args) do
    cond do
      length(args) != 2 ->
        Mix.shell().info("Needs to receive a file URL and a flag.")

      true ->
        args |> create
    end
  end

  defp create(args) do
    Mix.Task.run("app.start")

    file_url = Enum.at(args, 0)
    location_flag = Enum.at(args, 1)

    case location_flag do
      "Local" ->
        try do
          file_url
          |> parse_csv
          |> create_users
        rescue
          e in File.Error -> IO.inspect e
        end

       "Remote" ->

        :inets.start()
        :ssl.start()

        case :httpc.request(:get, {to_charlist(file_url), []}, [], stream: '/tmp/user.csv') do
          {:ok, _resp} ->
            "/tmp/user.csv"
            |> parse_csv
            |> create_users

          {:error, resp} -> IO.inspect resp
        end
    end


  end

  defp parse_csv(path) do
    path
    |> File.stream!(read_ahead: 1_000)
    |> CSV.parse_stream()
    |> Stream.map(fn row ->
      %{
        name: "#{Enum.at(row, 0)} #{Enum.at(row, 1)}",
        username: Enum.at(row, 2),
        admin: Enum.at(row, 3)
      }
    end)
  end

  defp create_users(user_csv_stream) do
    Enum.map(user_csv_stream, fn user_csv_entry ->
      email = Enum.join(["#{user.username}", @domain], "@")
      password = random_string(8)

      user = %{
        "email" => email,
        "name" => user.name,
        "password" => password,
        "password_confirmation" => password,
        "is_admin" => admin
      }

      Accounts.create_manager(%{"user" => user})
    end)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
