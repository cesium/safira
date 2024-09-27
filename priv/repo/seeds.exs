defmodule Safira.Repo.Seeds do
  @moduledoc """
  Script for populating the database.
  You can run it as:
    $ mix run priv/repo/seeds.exs # or mix ecto.seed
  """
  @seeds_dir "priv/repo/seeds"

  def run do
    [
      "courses.exs",
      "accounts.exs",
      "badges.exs",
      "store.exs",
      "vault.exs",
      "prizes.exs"
    ]
    |> Enum.each(fn file ->
      Code.require_file("#{@seeds_dir}/#{file}")
    end)
  end
end

Safira.Repo.Seeds.run()
