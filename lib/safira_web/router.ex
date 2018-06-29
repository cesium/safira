defmodule SafiraWeb.Router do
  use SafiraWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SafiraWeb do
    pipe_through :api
  end
end
