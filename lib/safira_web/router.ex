defmodule SafiraWeb.Router do
  use SafiraWeb, :router

  alias Safira.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/api", SafiraWeb do
    pipe_through :api

    post "/sign_up", AuthController, :sign_up
    post "/sign_in", AuthController, :sign_in

    scope "/v1" do
      pipe_through :jwt_authenticated

      get "/user", AuthController, :user

      resources "/badges", BadgeController, only: [:index, :show]

      resources "/attendees", AttendeeController, except: [:create]
    end
  end
end
