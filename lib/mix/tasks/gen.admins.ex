defmodule Mix.Tasks.Gen.Admins do
  use Mix.Task
  alias Safira.Admin.Accounts

  @domain "seium.org"

  def run(args) do
    cond do
      length(args) == 0 ->
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
      email = Enum.join(["admin#{man_num() + 1}", @domain], "@")
      password = random_string(8)

      admin_user = %{
        "email" => email,
        "password" => password,
        "password_confirmation" => password
      }

      Pow.Ecto.Context.create(admin_user, otp_app: :safira)

      IO.puts("#{email}:#{password}")
    end)
  end

  defp man_num() do
    Accounts.list_admin_users()
    |> List.last()
    |> give_num
  end

  defp give_num(n) do
    unless is_nil(n) do
      Map.get(n, :id)
    else
      0
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
