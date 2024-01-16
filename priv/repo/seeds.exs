# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Safira.Repo.insert!(%Safira.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule Safira.Repo.Seeds do
  @seeds_dir "priv/repo/seeds"

  def run do
    @seeds_dir
    |> File.ls!()
    |> Enum.sort()
    |> Enum.each(fn file ->
      Code.require_file("#{@seeds_dir}/#{file}")
    end)
  end
end

Safira.Repo.Seeds.run()
