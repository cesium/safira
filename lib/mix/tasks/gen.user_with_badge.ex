defmodule Mix.Tasks.Gen.UserWithBadge do
  use Mix.Task
  alias Ecto.Multi
  alias Safira.Accounts.Attendee
  alias Safira.Contest.Redeem
  alias Safira.Contest
  alias Safira.Repo
  alias Safira.Accounts.User

  NimbleCSV.define(EneiParser, separator: ",", escape: "\"")

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

    with {:ok, :saved_to_file} <-
           :httpc.request(:get, {to_charlist(url), []}, [], stream: '/tmp/elixir') do
      parse_csv("/tmp/elixir") |> create_user_give_badge
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
            multi
            |> Multi.insert(
              :redeem1,
              fn %{attendee: attendee} ->
                Redeem.changeset(
                  %Redeem{},
                  %{
                    attendee_id: attendee.id,
                    badge_id: badge_1.id
                  }
                )
              end
            )
            |> Multi.insert(
              :redeem2,
              fn %{attendee: attendee} ->
                Redeem.changeset(
                  %Redeem{},
                  %{
                    attendee_id: attendee.id,
                    badge_id: badge_2.id
                  }
                )
              end
            )
            |> Multi.insert(
              :redeem3,
              fn %{attendee: attendee} ->
                Redeem.changeset(
                  %Redeem{},
                  %{
                    attendee_id: attendee.id,
                    badge_id: badge_3.id
                  }
                )
              end
            )
          user_csv.housing == "Alojamento D. Maria II" ->
            multi
            |> Multi.insert(
              :redeem4,
              fn %{attendee: attendee} ->
                Redeem.changeset(
                  %Redeem{},
                  %{
                    attendee_id: attendee.id,
                    badge_id: badge_10.id
                  }
                )
              end
            )
          user_csv.housing == "Alojamento Alberto Sampaio" ->
            multi
            |> Multi.insert(
              :redeem5,
              fn %{attendee: attendee} ->
                Redeem.changeset(
                  %Redeem{},
                  %{
                    attendee_id: attendee.id,
                    badge_id: badge_11.id
                  }
                )
              end
            )
        end

      multi = 
        if user_csv.food == 0 do
          multi
          |> Multi.insert(
            :redeem6,
            fn %{attendee: attendee} ->
              Redeem.changeset(
                %Redeem{},
                %{
                  attendee_id: attendee.id,
                  badge_id: badge_4.id
                }
              )
            end
          )
          |> Multi.insert(
            :redeem7,
            fn %{attendee: attendee} ->
              Redeem.changeset(
                %Redeem{},
                %{
                  attendee_id: attendee.id,
                  badge_id: badge_5.id
                }
              )
            end
          )
          |> Multi.insert(
            :redeem8,
            fn %{attendee: attendee} ->
              Redeem.changeset(
                %Redeem{},
                %{
                  attendee_id: attendee.id,
                  badge_id: badge_6.id
                }
              )
            end
          )
          |> Multi.insert(
            :redeem9,
            fn %{attendee: attendee} ->
              Redeem.changeset(
                %Redeem{},
                %{
                  attendee_id: attendee.id,
                  badge_id: badge_7.id
                }
              )
            end
          )
          |> Multi.insert(
            :redeem10,
            fn %{attendee: attendee} ->
              Redeem.changeset(
                %Redeem{},
                %{
                  attendee_id: attendee.id,
                  badge_id: badge_8.id
                }
              )
            end
          )
          |> Multi.insert(
            :redeem11,
            fn %{attendee: attendee} ->
              Redeem.changeset(
                %Redeem{},
                %{
                  attendee_id: attendee.id,
                  badge_id: badge_9.id
                }
              )
            end
          )
        else
          multi
        end

      multi
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
    |> File.stream!(read_ahead: 1_000)
    |> EneiParser.parse_stream()
    |> Stream.map(fn [name, lastname, email, housing, food] ->
      %{
        name: "#{name} #{lastname}",
        email: email,
        housing: housing,
        food: String.to_integer(food)
      }
    end)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
