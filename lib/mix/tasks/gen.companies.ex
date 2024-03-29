defmodule Mix.Tasks.Gen.Companies do
  @moduledoc """
  Task to generate companies
  """
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSV

  alias Safira.Accounts

  # Its waiting for an header or an empty line on the beggining of the file

  # Task which will generate both the badges and the accounts for each company
  # Makes obsolete gen.company and gen.badges for the companies csv
  @domain "seium.org"

  def run(args) do
    if Enum.empty?(args) do
      Mix.shell().info("Needs to receive at least one file path.")
    else
      args |> create
    end
  end

  defp create(path) do
    Mix.Task.run("app.start")

    path
    |> parse_csv()
    |> sequence()
    |> create_badges()
    |> insert_companies()
  end

  defp create_badges({create, update, accounts_info}) do
    {Safira.Contest.create_badges(create), update, accounts_info}
  end

  defp parse_csv(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn [
                       name,
                       description,
                       begin_time,
                       end_time,
                       begin_badge_time,
                       end_badge_time,
                       image_path,
                       type,
                       tokens,
                       sponsorship,
                       channel_id,
                       cv_access
                     ] ->
      {:ok, begin_datetime, _} = DateTime.from_iso8601(begin_time)
      {:ok, end_datetime, _} = DateTime.from_iso8601(end_time)
      {:ok, begin_badge_datetime, _} = DateTime.from_iso8601(begin_badge_time)
      {:ok, end_badge_datetime, _} = DateTime.from_iso8601(end_badge_time)

      {
        %{
          name: name,
          description: description,
          begin: begin_datetime,
          end: end_datetime,
          begin_badge: begin_badge_datetime,
          end_badge: end_badge_datetime,
          type: String.to_integer(type),
          tokens: String.to_integer(tokens)
        },
        %{
          avatar: get_avatar(image_path)
        },
        %{
          name: name,
          sponsorship: sponsorship,
          channel_id: channel_id,
          remaining_spotlights: sponsorship_to_spotlights(sponsorship),
          has_cv_access: String.to_integer(cv_access) != 0
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

  defp sequence(list) do
    create = Enum.map(list, fn value -> elem(value, 0) end)
    update = Enum.map(list, fn value -> elem(value, 1) end)
    accounts_info = Enum.map(list, fn value -> elem(value, 2) end)
    {create, update, accounts_info}
  end

  defp insert_companies({insert_transactions, updates, accounts_info}) do
    case Safira.Repo.transaction(insert_transactions) do
      {:ok, result} ->
        Enum.zip([result, updates, accounts_info])
        |> update_badges
        |> Enum.map(fn acc_struct -> Accounts.create_company(acc_struct) end)
        |> Enum.each(&print_insert_company/1)

      {:error, error} ->
        Mix.shell().info(error)
    end
  end

  defp print_insert_company(res) do
    case res do
      {:ok, acc_details} ->
        Mix.shell().info("#{acc_details.user.email}:#{acc_details.user.password}")

      {:error, changeset} ->
        Mix.shell().info("Error creating account for #{changeset.changes.name}")
    end
  end

  # returns the accounts_info map for each account now filled with the badge_id
  defp update_badges(information_zip) do
    information_zip
    |> Enum.map(fn {insertion_results, update, account_info} ->
      with {:ok, badge} <- Safira.Contest.update_badge(elem(insertion_results, 1), update) do
        account_info
        |> Map.put(:badge_id, badge.id)
        |> Map.put(:user, create_user(account_info.name))
      end
    end)
  end

  defp create_user(name) do
    email =
      Enum.join(
        [
          name
          |> String.downcase()
          |> String.replace(" ", "")
          |> String.replace("&", "_")
          |> String.replace("/", "_")
          |> String.split("(")
          |> List.first(),
          @domain
        ],
        "@"
      )

    password = random_string(8)

    %{
      "email" => email,
      "password" => password,
      "password_confirmation" => password
    }
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  defp sponsorship_to_spotlights(sponsorship) do
    case sponsorship do
      "Exclusive" -> 3
      "Gold" -> 2
      "Silver" -> 1
      "Bronze" -> 1
    end
  end
end
