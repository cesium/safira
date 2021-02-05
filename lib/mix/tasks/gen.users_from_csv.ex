defmodule Mix.Tasks.Gen.UsersFromCsv do
  use Mix.Task
  alias Ecto.Multi
  alias Safira.Repo
  alias Safira.Auth
  alias Safira.Accounts.User
  alias Safira.Accounts.Attendee

  NimbleCSV.define(SeiParser, separator: ",", escape: "\"")

  def run(args) do
    cond do
      Enum.empty?(args) ->
        Mix.shell().info("Needs to receive a file URL.")

      true ->
        args |> List.first() |> create
    end
  end

  defp create(path) do
    Mix.Task.run("app.start")

    if File.exists?(path) do
      path
      |> parse_csv
      |> create_users
    else
      IO.puts("File does not exist")
    end
  end

  defp parse_csv(path) do
    path
    |> File.stream!(read_ahead: 1_000)
    |> SeiParser.parse_stream()
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
      |> send_mail()
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

  defp send_mail(transaction) do
    case transaction do
      {:ok, changes} ->
        user = Auth.reset_password_token(changes.user)

        Safira.Email.send_password_email(user.email, user.reset_password_token)
        |>Safira.Mailer.deliver_now()

      _ ->
        transaction
    end
  end
end
