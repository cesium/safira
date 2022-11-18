defmodule Mix.Tasks.Gen.AttendeesWithPassword do
  @moduledoc """
  Task to generate attendees with passwords
  """

  use Mix.Task
  alias Safira.Accounts

  @domain "seium.org"

  def run(args) do
    cond do
      Enum.empty?(args) ->
        Mix.shell().info("Needs to receive a number greater than 0.")

      args |> List.first() |> String.to_integer() <= 0 ->
        Mix.shell().info("Needs to receive a number greater than 0.")

      true ->
        args |> List.first() |> String.to_integer() |> create()
    end
  end

  defp create(number) do
    Mix.Task.run("app.start")

    Enum.each(1..number, fn n ->
      nickname = "attendee#{n}"
      email = Enum.join([nickname, @domain], "@")
      password = random_string(8)

      user = %{
        "email" => email,
        "password" => password,
        "password_confirmation" => password
      }

      account =
        Accounts.create_attendee(%{"name" => nickname, "nickname" => nickname, "user" => user})
        |> elem(1)

      IO.puts("#{email}:#{password}")
    end)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
