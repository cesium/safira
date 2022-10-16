defmodule Mix.Tasks.Reset.Password do
  @moduledoc """
  Task to reset the password of a user
  """
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Accounts.User

  alias Safira.Repo

  def run(args) do
    cond do
      Enum.empty?(args) ->
        Mix.shell().info("Needs to receive an user email.")

      true ->
        args |> List.first() |> create
    end
  end

  defp create(email) do
    Mix.Task.run("app.start")

    with %User{} = user <- Repo.get_by(User, email: email) do
      user
      |> Accounts.update_user(%{
        password: password_get("Password:", true) |> String.trim(),
        password_confirmation: password_get("Password confirmation:", true) |> String.trim()
      })
    end
  end

  # https://github.com/hexpm/hex/blob/1523f44e8966d77a2c71738629912ad59627b870/lib/mix/hex/utils.ex#L32-L58
  # Password prompt that hides input by every 1ms
  # clearing the line with stderr
  def password_get(prompt, false) do
    IO.gets(prompt <> " ")
  end

  def password_get(prompt, true) do
    pid = spawn_link(fn -> loop(prompt) end)
    ref = make_ref()
    value = IO.gets(prompt <> " ")

    send(pid, {:done, self(), ref})
    receive do: ({:done, ^pid, ^ref} -> :ok)

    value
  end

  defp loop(prompt) do
    receive do
      {:done, parent, ref} ->
        send(parent, {:done, self, ref})
        IO.write(:standard_error, "\e[2K\r")
    after
      1 ->
        IO.write(:standard_error, "\e[2K\r#{prompt} ")
        loop(prompt)
    end
  end
end
