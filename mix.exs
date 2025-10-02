defmodule Safira.MixProject do
  use Mix.Project

  def project do
    [
      app: :safira,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
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
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # core
      {:phoenix, "~> 1.8.1"},
      {:phoenix_live_view, "~> 1.1.13"},
      {:phoenix_live_reload, "~> 1.6.1", only: :dev},

      # database
      {:ecto_sql, "~> 3.10"},
      {:phoenix_ecto, "~> 4.6.5"},
      {:postgrex, ">= 0.0.0"},
      {:flop, "~> 0.25.0"},

      # security
      {:bcrypt_elixir, "~> 3.3.2"},

      # uploads
      {:waffle_ecto, "~> 0.0.12"},
      {:waffle, "~> 1.1.9"},
      {:ex_aws, "~> 2.1.2"},
      {:ex_aws_s3, "~> 2.5.8"},
      {:hackney, "~> 1.25.0"},
      {:httpoison, "~> 2.2.3"},
      {:sweet_xml, "~> 0.7.5"},
      {:zstream, "~> 0.6.7"},

      # mailer
      {:swoosh, "~> 1.17.6"},
      {:phoenix_swoosh, "~> 1.2.1"},
      {:gen_smtp, "~>1.2.0"},
      {:phoenix_html, "~> 4.3.0"},
      {:finch, "~> 0.20.0"},

      # tools
      {:qrcode_ex, "~> 0.1.1"},
      {:credo, "~> 1.7.12", only: [:dev, :test], runtime: false},
      {:faker, "~> 0.18.0"},
      {:earmark, "~> 1.4.48"},

      # frontend
      {:tailwind, "~> 0.4.0", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:fontawesome,
       github: "FortAwesome/Font-Awesome",
       tag: "6.6.0",
       sparse: "svgs",
       app: false,
       compile: false,
       depth: 1},
      {:esbuild, "~> 0.10.0", runtime: Mix.env() == :dev},
      {:live_select, "~> 1.7.1"},

      # monitoring
      {:telemetry_metrics, "~> 1.1.0"},
      {:telemetry_poller, "~> 1.3.0"},
      {:phoenix_live_dashboard, "~> 0.8.7"},

      #  utilities
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:timex, "~> 3.7.11"},
      {:nimble_csv, "~>1.1.0"},

      # server
      {:bandit, "~> 1.8.0"},
      {:dns_cluster, "~> 0.1.3"},

      # jobs
      {:oban, "~> 2.20.1"},

      # testing
      {:lazy_html, ">= 0.1.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind safira", "esbuild safira"],
      "assets.deploy": [
        "tailwind safira --minify",
        "esbuild safira --minify",
        "phx.digest"
      ],
      lint: ["credo --all --strict"]
    ]
  end
end
