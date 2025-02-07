defmodule SafiraWeb.Presence do
  @moduledoc """
  Wrapper for `Phoenix.Presence` to use in Safira.
  """
  use Phoenix.Presence, otp_app: :safira, pubsub_server: Safira.PubSub

  alias Phoenix.PubSub

  @topic "presence:safira"
  @pubsub Safira.PubSub

  def list_presences, do: list(@topic)

  def add_presence(pid, id, data), do: track(pid, @topic, id, data)

  def subscribe, do: PubSub.subscribe(@pubsub, @topic)
end
