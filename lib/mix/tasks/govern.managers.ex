defmodule Mix.Tasks.Govern.Managers do
  @moduledoc """
  Task to activate all manager accounts
  """
  use Mix.Task

  def run(args) do
    cond do
      Enum.empty?(args) || length(args) > 2 ->
        Mix.shell().info("Needs to receive a email and the active value.")

      List.last(args) != "false" && List.last(args) != "true" ->
        Mix.shell().info("Needs to receive a bool.")

      true ->
        create(List.first(args), String.to_existing_atom(List.last(args)))
    end
  end

  defp create(email, value) do
    Mix.Task.run("app.start")

    Safira.Accounts.get_manager_by_email(email)
    |> List.first()
    |> Safira.Accounts.update_manager(%{active: value})
  end
end
