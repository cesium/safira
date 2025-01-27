defmodule SafiraWeb.Presence do
  @moduledoc """
  Wrapper for `Phoenix.Presence` to use in Safira.
  """
  use Phoenix.Presence, otp_app: :safira, pubsub_server: Safira.PubSub

  defmodule __MODULE__.Diff do
    @moduledoc """
    Struct to represent the diff of presences.
    """

    @keys ~w(joins leaves)a
    @enforce_keys @keys
    defstruct @keys
  end

  @server __MODULE__.Server

  defdelegate list_presences, to: @server

  defdelegate add_presence(pid, id, data), to: @server

  defdelegate subscribe, to: @server
end
