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

  @voluntary_shutdown_reasons [:closed, :peer_closed]

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
    Logger.info("Adding presence for #{inspect(pid)}")
    Presence.track(pid, @topic, id, data)
    Process.monitor(pid)

    state = Map.put(state, id, pid)
    {:noreply, state}
  end

  @impl true
  def handle_info(%Broadcast{topic: @topic, event: "presence_diff", payload: payload}, state) do
    Logger.info("Broadcasting presence diff")
    diff = %Presence.Diff{joins: payload[:joins], leaves: payload[:leaves]}
    PubSub.broadcast(@pubsub, @topic <> ":diff", diff)

    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, {:shutdown, reason}}, state) when reason in @voluntary_shutdown_reasons do
    Logger.info("[First clause] Process #{inspect(pid)} went down for reason #{inspect(reason)}")

    case get_id_by_pid(pid, state) do
      nil ->
        {:noreply, state}

      id ->
        Logger.info("Removing presence for #{inspect(pid)}")
        Presence.untrack(pid, @topic, id)

        state = Map.delete(state, id)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, {:shutdown, reason}}, state) do
    Logger.info("[Second clause] Process went down for reason #{inspect(reason)}")

    case get_id_by_pid(pid, state) do
      nil ->
        {:noreply, state}

      id ->
        Logger.info("Readding presence for #{inspect(pid)}, since shutdown reason was not voluntary")
        Presence.track(pid, @topic, id, get_presence_data_by_id(id))

        {:noreply, state}
    end
  end

  defp get_presence_data_by_id(id) do
    %{metas: [data]} = Presence.get_by_key(@topic, id)
    data
  end

  defp get_id_by_pid(pid, state) do
    case Enum.find(state, fn {_id, p} -> p == pid end) do
      nil -> nil
      {id, _} -> id
    end
  end
end
