defmodule Safira.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SafiraWeb.Telemetry,
      Safira.Repo,
      Safira.Standalone,
      {DNSCluster, query: Application.get_env(:safira, :dns_cluster_query) || :ignore},
      # Start the PubSub system
      {Phoenix.PubSub, name: Safira.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Safira.Finch},
      # Start a worker by calling: Safira.Worker.start_link(arg)
      # {Safira.Worker, arg},
      # Start to serve requests, typically the last entry
      SafiraWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Safira.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SafiraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
