defmodule SafiraWeb.Presence.Server do
  @moduledoc """
  Server responsible for handling presence tracking
  diffing and broadcasting in the application.
  """
  use GenServer

  alias SafiraWeb.Presence
  alias Phoenix.PubSub
  alias Phoenix.Socket.Broadcast

  require Logger

  @topic "presence:safira"
  @pubsub Safira.PubSub

  ## Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def list_presences, do: Presence.list(@topic)

  def add_presence(pid, id, data) do
    GenServer.cast(__MODULE__, {:add_presence, pid, id, data})
  end

  def subscribe, do: PubSub.subscribe(@pubsub, @topic <> ":diff")

  ## Server (callbacks)

  @impl true
  def init(_opts) do
    PubSub.subscribe(@pubsub, @topic)

    Logger.info("Presence server started")

    {:ok, %{}}
  end

  @impl true
  def handle_cast({:add_presence, pid, id, data}, state) do
    Presence.track(pid, @topic, id, data)

    state = Map.put(state, id, pid)
    {:noreply, state}
  end

  @impl true
  def handle_info(%Broadcast{topic: @topic, event: "presence_diff", payload: payload}, state) do
    diff = %Presence.Diff{joins: payload[:joins], leaves: payload[:leaves]}
    PubSub.broadcast(@pubsub, @topic <> ":diff", diff)

    {:noreply, state}
  end
end
