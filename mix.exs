defmodule Safira.MixProject do
  use Mix.Project

  def project do
    [
      app: :safira,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
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

  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.1"},
      {:bamboo, "~> 2.2"},
      {:bcrypt_elixir, "~> 1.1"},
      {:bureaucrat, "~> 0.2.7", only: :test},
      {:comeonin, "~> 4.1"},
      {:corsica, "~> 1.1"},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.7"},
      # If using Amazon S3
      {:ex_aws, "~> 2.2"},
      {:ex_aws_s3, "~> 2.3"},
      {:ex_machina, "~> 2.7", only: :test},
      {:gettext, "~> 0.18"},
      {:guardian, "~> 2.2"},
      {:hackney, "~> 1.18"},
      {:httpoison, "~> 0.13"},
      {:jason, "~> 1.2"},
      {:nimble_csv, "~> 0.7"},
      {:phoenix, "~> 1.6", override: true},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_html, "~> 2.14"},
      {:plug_cowboy, "~> 2.5"},
      {:poison, "~> 3.1"},
      {:postgrex, ">= 0.0.0", override: true},
      {:pow, "~> 1.0"},
      {:sweet_xml, "~> 0.7"},
      {:timex, "~> 3.7"},
      {:torch, "~> 3.6"},
      {:qr_code_svg, git: "https://github.com/ondrej-tucek/qr-code-svg", tag: "v1.2.0"},
      {:xml_builder, "~> 2.2"}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
