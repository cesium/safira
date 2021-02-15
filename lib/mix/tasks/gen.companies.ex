defmodule Mix.Tasks.Gen.Companies do
  use Mix.Task

  alias Safira.Accounts
  alias NimbleCSV.RFC4180, as: CSV

  # Its waiting for an header or an empty line on the beggining of the file

  # Task which will generate both the badges and the accounts for each company
  # Makes obsolete gen.company and gen.badges for the companies csv
  @domain "seium.org"

  def run(args) do
    cond do
      length(args) == 0 ->
        Mix.shell().info("Needs to receive atleast one file path.")

      true ->
        args |> create
    end
  end

  defp create(path) do
    Mix.Task.run("app.start")

    path
    |> parse_csv
    |> sequence
    |> (fn {create, update, accounts_info} ->
          {Safira.Contest.create_badges(create), update, accounts_info}
        end).()
    |> insert_companies
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
                       image_path,
                       type,
                       tokens,
                       sponsorship,
                       channel_id
                     ] ->
      {:ok, begin_datetime, _} = DateTime.from_iso8601("#{begin_time}T00:00:00Z")
      {:ok, end_datetime, _} = DateTime.from_iso8601("#{end_time}T00:00:00Z")

      {
        %{
          name: name,
          description: description,
          begin: begin_datetime,
          end: end_datetime,
          type: String.to_integer(type),
          tokens: String.to_integer(tokens)
        },
        %{
          avatar: %Plug.Upload{
            filename: check_image_filename(image_path),
            path: check_image_path(image_path)
          }
        },
        %{
          name:
            name
            |> String.downcase()
            |> String.replace(" ", "")
            |> String.replace("&", "_")
            |> String.replace("/", "_")
            |> String.split("(")
            |> List.first(),
          sponsorship: sponsorship,
          channel_id: channel_id
        }
      }
    end)
  end

  defp check_image_filename(image_path) do
    if is_nil(image_path) do
      "badge-missing.png"
    else
      String.split(image_path, "/") |> List.last()
    end
  end

  defp check_image_path(image_path) do
    if is_nil(image_path) do
      "#{File.cwd!()}/assets/static/images/badge-missing.png"
    else
      image_path
    end
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
        |> Enum.each(fn res ->
          case res do
            {:ok, acc_details} ->
              Mix.shell().info("#{acc_details.user.email}:#{acc_details.user.password}")

            {:error, changeset} ->
              Mix.shell().info("Error creating account for #{changeset.changes.name}")
          end
        end)

      {:error, error} ->
        Mix.shell().info(error)
    end
  end

  # returns the accounts_info map for each account now filled with the badge_id
  defp update_badges(information_zip) do
    information_zip
    |> Enum.map(fn {insertion_results, update, account_info} ->
      with {:ok, badge} = Safira.Contest.update_badge(elem(insertion_results, 1), update) do
        account_info
        |> Map.put(:badge_id, badge.id)
        |> Map.put(:user, create_user(account_info.name))
      end
    end)
  end

  defp create_user(name) do
    email = Enum.join([name, @domain], "@") |> String.downcase()
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
end
