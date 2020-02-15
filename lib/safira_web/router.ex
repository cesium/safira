defmodule SafiraWeb.Router do
  use SafiraWeb, :router
  use Pow.Phoenix.Router

  alias Safira.Guardian

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/", SafiraWeb do
    get "/", PageController, :index
  end

  scope "/api", SafiraWeb do
    pipe_through :api

    scope "/auth" do
      post "/sign_up", AuthController, :sign_up
      post "/sign_in", AuthController, :sign_in
      
      resources "/passwords", PasswordController, only: [:create, :update]
    end

    scope "/v1" do
      get "/is_registered/:id", AuthController, :is_registered

      pipe_through :jwt_authenticated

      get "/user", AuthController, :user
      get "/attendee", AuthController, :attendee
      get "/leaderboard", LeaderboardController, :index

      resources "/badges", BadgeController, only: [:index, :show]
      resources "/attendees", AttendeeController, except: [:create]
      resources "/referrals", ReferralController, only: [:show]
      resources "/companies", CompanyController, only: [:index, :show]
      resources "/redeems", RedeemController, only: [:create]
    end
  end

  scope "/" do
    pipe_through :browser

    pow_session_routes()
  end

  #scope "/", Pow.Phoenix, as: "pow" do
  #  pipe_through [:browser, :protected]
  #  resources "/registration", RegistrationController, singleton: true, only: [:edit, :update]
  #end

  scope "/admin", SafiraWeb.Admin, as: :admin do
    pipe_through [:browser, :protected]

    resources "/badges", BadgeController
  end
end
