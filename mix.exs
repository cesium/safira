defmodule Safira.Mixfile do
  use Mix.Project

  def project do
    [
      app: :safira,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Safira.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test) do 
    [
      "lib", 
      "test/support",
      "test/factories",
      "test/strategies"
    ]
  end
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:guardian, "~> 1.0"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:qr_code_svg, git: "https://github.com/ondrej-tucek/qr-code-svg", tag: "v1.2.0"},
      {:corsica, "~> 1.0"},
      {:arc, "~> 0.11.0"},
      # If using Amazon S3
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:sweet_xml, "~> 0.6"},
      {:arc_ecto, "~> 0.11.1"},
      {:xml_builder, "~> 2.0", override: true},
      {:nimble_csv, "~> 0.3"},
      {:bamboo, "~> 1.4"},
      {:timex, "~> 3.5"},
      {:ex_machina, "~> 2.3", only: :test},
      {:bureaucrat, "~> 0.2.5", only: :test},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
