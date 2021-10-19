# Safira [![Build Status](https://travis-ci.com/cesium/safira.svg?branch=master)](https://travis-ci.com/cesium/safira)

# Endpoints
SEND HELP

[Endpoints](doc/endpoints.md)

# Documentation

Before you start, make sure you have the correct environment set. Use
`.env.sample` as a starter (`cp .env.sample .env`). Fill in the correct
information and then export its values (either `source .env` or install
[direnv](https://direnv.net)).

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To generate API documentation:
  
  * Install [Aglio](https://github.com/danielgtaylor/aglio) `npm install -g aglio`
  * Run the task `mix doc.api DOC=1`

