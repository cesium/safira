defmodule Mix.Tasks.Gen.Staffs do
  @moduledoc """
  Task to generate staffs
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
        args |> List.first() |> String.to_integer() |> create
    end
  end

  defp create(n) do
    Mix.Task.run("app.start")

    Enum.each(1..n, fn _n ->
      email = Enum.join(["staff#{man_num() + 1}", @domain], "@")
      password = random_string(8)

      user = %{
        "email" => email,
        "password" => password,
        "password_confirmation" => password
      }

      Accounts.create_staff(%{"user" => user, "nickname" => "staff#{man_num() + 1}"})

      IO.puts("#{email}:#{password}")
    end)
  end

  defp man_num do
    Accounts.list_staffs()
    |> List.last()
    |> give_num
  end

  defp give_num(n) do
    if is_nil(n) do
      0
    else
      Map.get(n, :id)
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
