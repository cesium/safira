defmodule Mix.Tasks.Gen.UserWithBadge do
  use Mix.Task
  alias Ecto.Multi
  alias Safira.Accounts.Attendee
  alias Safira.Contest.Redeem
  alias Safira.Contest
  alias Safira.Repo
  alias Safira.Accounts.User
  alias Safira.Auth

  NimbleCSV.define(SeiParser, separator: ",", escape: "\"")
  # Use header

  def run(args) do
    cond do
      Enum.empty?(args) ->
        Mix.shell().info("Needs to receive a file URL.")

      true ->
        args |> List.first() |> create
    end
  end

  defp create(url) do
    Mix.Task.run("app.start")

    :inets.start()
    :ssl.start()

    case :httpc.request(:get, {to_charlist(url), []}, [], stream: '/tmp/user.csv') do
      {:ok, _resp} ->
        IO.inspect(parse_csv("/tmp/user.csv"))
        # |> create_user_give_badge

      {:error, resp} -> IO.inspect resp
    end
  end

  defp create_user_give_badge(list_user_csv) do
    badge_1  = Contest.get_badge_name!("Pequeno-almoço segunda")
    badge_2  = Contest.get_badge_name!("Pequeno-almoço terça")
    badge_3  = Contest.get_badge_name!("Pequeno-almoço quarta")
    badge_4  = Contest.get_badge_name!("Almoço segunda")
    badge_5  = Contest.get_badge_name!("Almoço terça")
    badge_6  = Contest.get_badge_name!("Almoço quarta")
    badge_7  = Contest.get_badge_name!("Jantar domingo")
    badge_8  = Contest.get_badge_name!("Jantar segunda (Mega febrada)")
    badge_9  = Contest.get_badge_name!("Jantar terça")
    badge_10 = Contest.get_badge_name!("Alojamento D. Maria II")
    badge_11 = Contest.get_badge_name!("Alojamento Alberto Sampaio")

    Enum.map(list_user_csv, fn user_csv ->
      multi =
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

      multi =
        cond do
          user_csv.housing == "Não tem" ->
            Enum.reduce(
              [badge_1, badge_2, badge_3],
              multi,
              fn badge, acc ->
                give_badge(badge.id, acc)
            end)
          user_csv.housing == "Alojamento D. Maria II" ->
            give_badge(badge_10.id, multi)
          user_csv.housing == "Alojamento Alberto Sampaio" ->
            give_badge(badge_11.id, multi)
        end

      multi =
        if user_csv.food == 0 do
          Enum.reduce(
            [badge_4, badge_5, badge_6, badge_7, badge_8, badge_9],
            multi,
            fn badge, acc ->
              give_badge(badge.id, acc)
          end)
        else
          multi
        end

      multi
      |> Repo.transaction()
      |> send_mail()
    end)
  end

  defp send_mail(transaction) do
    case transaction do
      {:ok, changes} ->
        user = Auth.reset_password_token(changes.user)

        Safira.Email.send_password_email(user.email, user.reset_password_token)
        |>Safira.Mailer.deliver_now()

      _ -> transaction
    end
  end

  defp give_badge(badge_id, multi) do
    Multi.insert(
      multi,
      badge_id,
      fn %{attendee: attendee} ->
        Redeem.changeset(
          %Redeem{},
          %{
            attendee_id: attendee.id,
            badge_id: badge_id
          }
        )
      end
    )
  end

  defp create_user_aux(user) do
    password = random_string(8)

    user = %{
      "email" => user.email,
      "password" => password,
      "password_confirmation" => password
    }

    x = User.changeset(%User{}, user)
  end

  defp parse_csv(path) do
    path
    |> File.stream!(read_ahead: 1_000)
    |> SeiParser.parse_stream()
    |> Stream.map(fn row ->
      %{
        name: "#{Enum.at(row,2)} #{Enum.at(row,3)}",
        email: Enum.at(row,4),
        housing: nil, #old value: housing
        food: nil #old value: String.to_integer(food)
      }
    end)
  end


  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
