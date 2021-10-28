from elixir:latest

copy . /

run apt update
run apt install -y inotify-tools
run mix local.hex --force
run mix deps.get --force
run mix local.rebar --force

entrypoint mix ecto.setup --force; mix phx.server
