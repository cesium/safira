defmodule Mix.Tasks.Gift.Badge do
  @moduledoc """
  Task to gift a badge to an attendee
  """
  use Mix.Task

  alias Safira.Accounts

  alias Safira.Contest
  alias Safira.Contest.Badge

  # Note: the flag must always be present even though it is only used when a file is given
  def run(args) do
    cond do
      length(args) != 3 ->
        Mix.shell().info(
          "Needs to receive one file path or an attendee_id and a badge_id and a flag Local/Remote"
        )

      args |> Enum.at(1) |> String.to_integer() < 0 ->
        Mix.shell().info("Number of badge_id needs to be above 0.")

      true ->
        args |> create
    end
  end

  defp create(args) do
    Mix.Task.run("app.start")

    cond do
      is_valid_uuid(Enum.at(args, 0)) ->
        give_by_uuid(Enum.slice(args, 0, 2))

      is_valid_email(Enum.at(args, 0)) ->
        give_by_email(Enum.slice(args, 0, 2))

      true ->
        give_by_file(args)
    end
  end

  defp is_valid_email(email) do
    case valid_email(email |> String.trim()) do
      false -> false
      true -> is_register_email(email |> String.trim())
    end
  end

  defp is_register_email(email) do
    user = Accounts.get_user_preload_email!(email)
    not is_nil(user.attendee)
  end

  defp valid_email(email) do
    email
    |> String.trim()
    |> String.match?(~r/\A[^@\s]+@[^@\s]+\z/)
  end

  defp give_by_email(args) do
    badge_id = List.last(args) |> String.to_integer()

    if exists_badge(badge_id) do
      give_email(Enum.at(args, 0), badge_id)
    else
      Mix.shell().info("Badge_id needs to be valid.")
    end
  end

  defp give_by_file(args) do
    badge_id = Enum.at(args, 1) |> String.to_integer()
    location_flag = Enum.at(args, 2)

    if exists_badge(badge_id) do
      file_url = Enum.at(args, 0)

      case location_flag do
        "Local" ->
          file_url
          |> File.stream!()
          |> Enum.map(fn x -> give_check(x |> String.trim(), badge_id) end)

        "Remote" ->
          :inets.start()
          :ssl.start()

          case :httpc.request(:get, {to_charlist(file_url), []}, [], stream: '/tmp/user2.csv') do
            {:ok, _resp} ->
              "/tmp/user2.csv"
              |> File.stream!()
              |> Enum.each(fn x -> give_check(x |> String.trim(), badge_id) end)

            {:error, resp} ->
              # credo:disable-for-next-line
              IO.inspect(resp)
          end

          File.rm("/tmp/user2.csv")
      end
    else
      Mix.shell().info("Badge_id needs to be valid.")
    end
  end

  defp is_valid_uuid(arg) do
    case Ecto.UUID.cast(arg) do
      {:ok, _} -> is_register(arg)
      :error -> false
    end
  end

  defp is_valid_uuid?(arg) do
    case Ecto.UUID.cast(arg) do
      {:ok, _} -> true
      :error -> false
    end
  end

  defp is_register(id) do
    attendee = Accounts.get_attendee!(id)
    not is_nil(attendee.user_id)
  end

  defp give_by_uuid(args) do
    badge_id = List.last(args) |> String.to_integer()

    if exists_badge(badge_id) do
      give(Enum.at(args, 0), badge_id)
    else
      Mix.shell().info("Badge_id needs to be valid.")
    end
  end

  defp exists_badge(id) do
    case Safira.Repo.get(Badge, id) do
      %Badge{} = _badge -> true
      nil -> false
    end
  end

  defp give(attendee_id, badge_id) do
    Contest.create_redeem(
      %{attendee_id: attendee_id, staff_id: 1, badge_id: badge_id},
      :admin
    )
  end

  defp give_email(email, badge_id) do
    user = Accounts.get_user_preload_email(email)

    if is_nil(user) do
      Mix.shell().info("Invalid email: #{email}")
    else
      with {:error, _changeset} <- give(user.attendee.id, badge_id) do
        Mix.shell().info("Duplicate badge for #{email}")
      end
    end
  end

  defp give_check(input, badge_id) do
    cond do
      is_valid_uuid?(input) ->
        give(input, badge_id)

      valid_email(input) ->
        give_email(input, badge_id)
    end
  end
end
