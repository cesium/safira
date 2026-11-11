[mise]: https://mise.jdx.dev/

# 🚀 Getting Started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes.

## 📥 Prerequisites

The following software is required to be installed on your system:

- [Erlang 28+](https://www.erlang.org/downloads)
- [Elixir 1.19+](https://elixir-lang.org/install.html)
- [PostgreSQL 14+](https://www.postgresql.org/download/) (see
  [this section](#-docker) for setting it up with Docker)

We recommend using [mise][mise] to install and manage all the programming
languages' requirements. The required versions are listed in the
`.tool-versions` file, which mise reads.

If you prefer to use Docker, see the [section below](#-docker).

## 🔧 Setup

First, clone the repository:

```
git clone git@github.com:cesium/safira.git
cd safira
```

Then, if you are using mise, install the required tools:

```
mise install
```

Next, create your environment file and change it as needed:

```
cp .env.dev.sample .env.dev
```

| Variable           | Description                                                            |
| ------------------ | ---------------------------------------------------------------------- |
| `DB_USERNAME`      | Username of the Docker database (defaults to `postgres`)               |
| `DB_PASSWORD`      | Password of the Docker database (defaults to `postgres`)               |
| `ASSET_HOST`       | URL used to serve uploaded files (defaults to `http://localhost:4000`) |
| `UMAMI_SCRIPT_URL` | URL of the Umami analytics script                                      |
| `UMAMI_WEBSITE_ID` | Website ID in Umami                                                    |

Finally, get all dependencies configured. Make sure the database is up and
running. This also creates the database, runs the migrations and seeds it.

```
mix setup
```

## 🔨 Development

Start the development server and then you can open `http://localhost:4000`.

```
mix phx.server
```

Run the tests.

```
mix test
```

Lint your code.

```
mix lint
```

Format your code.

```
mix format
```

## 🐳 Docker

For data persistence this project uses a PostgreSQL database. You should have
PostgreSQL up and running.

If you want to set up the required database using Docker containers you can
easily do it with [Docker Compose](https://docs.docker.com/compose/install/).

Create the environment file, then create and start the database container. You
should use `linux.yml` if running on Linux and `darwin.yml` if running on macOS.

```
cp .env.dev.sample .env.dev
docker compose -f docker-compose.dev.yml -f {linux,darwin}.yml up db
```

Start the previously created containers.

```
docker compose -f docker-compose.dev.yml -f {linux,darwin}.yml start
```

Stop the containers.

```
docker compose -f docker-compose.dev.yml -f {linux,darwin}.yml stop
```

Destroy the containers and volumes created.

```
docker compose -f docker-compose.dev.yml -f {linux,darwin}.yml down -v
```

## 🔗 References

You can use these resources to learn more about the technologies this project
uses.

- [Getting Started with Elixir](https://elixir-lang.org/getting-started/introduction.html)
- [Erlang/Elixir Syntax: A Crash Course](https://elixir-lang.org/crash-course.html)
- [Elixir School Course](https://elixirschool.com/en/)
- [Phoenix Guides Overview](https://hexdocs.pm/phoenix/overview.html)
- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view)
- [Phoenix Documentation](https://hexdocs.pm/phoenix)
- [Ecto Documentation](https://hexdocs.pm/ecto)
