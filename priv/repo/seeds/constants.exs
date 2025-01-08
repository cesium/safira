defmodule Safira.Repo.Seeds.Constants do
  alias Safira.Constants
  alias Safira.Event

  def run do
    Constants.set("registrations_open", "true")
    Constants.set("start_time", "2024-09-29T17:57:00Z")

    for k <- Event.feature_flag_keys() do
      Constants.set(k, "true")
    end
  end
end

Safira.Repo.Seeds.Constants.run()
