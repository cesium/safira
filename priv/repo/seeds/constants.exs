defmodule Safira.Repo.Seeds.Constants do
  alias Safira.Constants

  def run do
    Constants.set("REGISTRATIONS_OPEN", "true")
    Constants.set("START_TIME", "2024-09-29T17:57:00Z")
  end
end

Safira.Repo.Seeds.Constants.run()
