defmodule Safira.Moon do
  @moduledoc """
  Lua runner.
  """

  def eval(code, args \\ []) do
    Lua.new(sandboxed: [])
    |> set_args(args)
    |> Lua.eval!(code)
    |> case do
      {[result], _} -> {:ok, result}
      _ -> {:ok, nil}
    end
  rescue
    e in [Lua.RuntimeException, Lua.CompilerException] ->
      {:error, e.message}
  end

  defp set_args(lua, args) do
    Enum.reduce(args, lua, fn {k, v}, state -> Lua.set!(state, [k], v) end)
  end
end
