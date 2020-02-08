defmodule Mix.Tasks.Gen.UserWithBadge do
  use Mix.Task
  alias Ecto.Multi
  alias Safira.Accounts.Attendee
  alias Safira.Contest.Redeem
  alias Safira.Repo
  alias Safira.Accounts.User

  NimbleCSV.define(EneiParser, separator: ",", escape: "\"")

  def run(args) do
    cond do
      Enum.empty?(args) ->
        Mix.shell.info "Needs to receive a file URL."
      true ->
        args |> List.first |> create
    end
  end

  defp create(url) do
    Mix.Task.run "app.start"

    :inets.start()
    :ssl.start()

    with {:ok, :saved_to_file} <- :httpc.request(:get, {to_charlist(url), []}, [], [stream: '/tmp/elixir']) do
      parse_csv("/tmp/elixir") |> create_user_give_badge
    end
  end

  defp create_user_give_badge(list_user_csv) do
    Enum.map(list_user_csv, fn user_csv -> 
      Multi.new()
      |> Multi.insert(
          :user,
          create_user_aux(user_csv)
      )
      |> Multi.insert(
          :attendee,
          fn %{user: user} ->
            Attendee.only_user_changeset(
              %Attendee{},
              %{
                user_id: user.id,
                name: user_csv.name
              }
            )
          end
        )
      |> Multi.insert(
          :redeem,
          fn %{attendee: attendee} ->
            Redeem.changeset(
              %Redeem{},
              %{
                attendee_id: attendee.id, 
                badge_id: 9
              }
            )
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

  defp parse_csv(path) do
    path
    |> File.stream!
    |> EneiParser.parse_stream
    |> Stream.map(
      fn [name, email, housing, food] ->
        %{
          name: name,
          email: email,
          housing: housing,
          food: food
        }
      end)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
