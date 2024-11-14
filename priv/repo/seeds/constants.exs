defmodule Safira.Repo.Seeds.Constants do
  alias Safira.Constants

  def run do
    Constants.set("registrations_open", "true")
    Constants.set("start_time", "2025-09-29T17:57:00Z")
  end
end

Safira.Repo.Seeds.Constants.run()
