defmodule Mix.Tasks.Gen.Company do
  use Mix.Task
  alias Safira.Accounts

  @domain "seium.org"

  def run(args) do
    cond do
      length(args) != 3 ->
        Mix.shell.info "Needs to receive a Company name, sponsorship and badge_id."
      args |> List.last |> String.to_integer < 0 ->
        Mix.shell.info "Number of badge_id needs to be above 0."
      true ->
        args |> create
    end
  end

  defp create(args) do
    Mix.Task.run "app.start"

    email = Enum.join([Enum.at(args,0), @domain], "@") |> String.downcase
    password = random_string(8)
    user = %{
      "email" => email,
      "password" => password,
      "password_confirmation" => password
    }

    Accounts.create_company(%{
      "name" => Enum.at(args,0),
      "sponsorship" => Enum.at(args,0),
      "badge_id" => args |> List.last |> String.to_integer,
      "user" => user
    })

    IO.puts "#{email}:#{password}"
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
