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
      {:phoenix, "~> 1.6.15"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.9"},
      {:postgrex, ">= 0.16.5"},
      {:phoenix_html, "~> 3.2"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:gettext, "~> 0.20.0"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.6"},
      {:guardian, "~> 2.3"},
      {:comeonin, "~> 5.3"},
      {:bcrypt_elixir, "~> 3.0"},
      {:qr_code_svg, git: "https://github.com/ondrej-tucek/qr-code-svg", tag: "v1.2.0"},
      {:corsica, "~> 1.3"},
      {:arc, "~> 0.11.0"},
      # If using Amazon S3
      {:ex_aws, "~> 2.4"},
      {:ex_aws_s3, "~> 2.3"},
      {:hackney, "~> 1.18"},
      {:httpoison, "~> 1.8.2"},
      {:poison, "~> 3.1"},
      {:sweet_xml, "~> 0.7.3"},
      {:arc_ecto, "~> 0.11.3"},
      {:xml_builder, "~> 2.2", override: true},
      {:nimble_csv, "~> 1.2"},
      {:bamboo, "~> 2.2"},
      {:timex, "~> 3.7"},
      {:torch, "~> 4.2"},
      {:pow, "~> 1.0.27"},
      {:ex_machina, "~> 2.7", only: :test},
      {:faker, "~> 0.17", only: :test},
      {:bureaucrat, "~> 0.2.9", only: :test},
      {:credo, "~> 1.6.7", only: [:dev, :test], runtime: false},
      {:http_stream, "~> 1.0.0", git: "https://github.com/coders51/http_stream"},
      {:zstream, "~> 0.6"}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      lint: ["credo --strict --all"]
    ]
  end
end
