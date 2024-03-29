defmodule Mix.Tasks.Gen.UsersFromCsvWithoutMail do
  @shortdoc "Generates the attendees from a CSV"

  @moduledoc """
  This task is waiting for a CSV where the 3rd collumn is name,
   4th collumn is last name and 5th collumn is email
  and a flag ("Local"/"Remote") indicating if the file is local or remote

  ex:
  mix gen.users_from_csv "assets/participantes_sei_exemplo.csv" "Local"
  mix gen.users_from_csv "https://sample.url.participantes_sei_exemplo.csv" "Remote"
  """
  use Mix.Task

  alias Ecto.Multi

  alias NimbleCSV.RFC4180, as: CSV

  alias Safira.Accounts.Attendee
  alias Safira.Accounts.User
  alias Safira.Auth

  alias Safira.Repo

  def run(args) do
    if length(args) != 2 do
      Mix.shell().info("Needs to receive a file URL and a flag.")
    else
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
          # credo:disable-for-next-line
          e in File.Error -> IO.inspect(e)
        end

      "Remote" ->
        :inets.start()
        :ssl.start()

        case :httpc.request(:get, {to_charlist(file_url), []}, [], stream: '/tmp/user.csv') do
          {:ok, _resp} ->
            "/tmp/user.csv"
            |> parse_csv
            |> create_users

          {:error, resp} ->
            # credo:disable-for-next-line
            IO.inspect(resp)
        end
    end
  end

  defp parse_csv(path) do
    path
    |> File.stream!(read_ahead: 1_000)
    |> CSV.parse_stream()
    |> Stream.map(fn row ->
      %{
        name: "#{Enum.at(row, 2)} #{Enum.at(row, 3)}",
        email: Enum.at(row, 4)
      }
    end)
  end

  defp create_users(user_csv_stream) do
    Enum.map(user_csv_stream, fn user_csv_entry ->
      Multi.new()
      |> Multi.insert(
        :user,
        create_user_aux(user_csv_entry)
      )
      |> Multi.insert(
        :attendee,
        fn %{user: user} ->
          create_attendee_aux(user, user_csv_entry)
        end
      )
      |> Repo.transaction()
    end)
  end

  defp create_user_aux(user) do
    password = random_string(8)

    user = %{
      "email" => user.email,
      "password" => password,
      "password_confirmation" => password
    }

    User.changeset(%User{}, user)
  end

  defp create_attendee_aux(user, user_csv_entry) do
    Attendee.only_user_changeset(
      %Attendee{},
      %{
        user_id: user.id,
        name: user_csv_entry.name
      }
    )
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
