defmodule Safira.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Safira.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Safira.PubSub},
      # Start the endpoint when the application starts
      SafiraWeb.Endpoint,
      # Start the cron-like job scheduler system
      Safira.JobScheduler
      # Starts a worker by calling: Safira.Worker.start_link(arg)
      # {Safira.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Safira.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SafiraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
