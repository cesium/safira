defmodule SafiraWeb.Router do
  use SafiraWeb, :router
  use Pow.Phoenix.Router

  alias Safira.Guardian

  if Mix.env() == :dev do
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

    get "/attendee/courses", CourseController, :index

    get "/is_registered/:id", AuthController, :is_registered

    pipe_through :jwt_authenticated

    get "/user", AuthController, :user
    get "/attendee", AuthController, :attendee
    get "/company", AuthController, :company
    get "/leaderboard", LeaderboardController, :index
    get "/leaderboard/:date", LeaderboardController, :daily
    get "/roulette/latestwins", RouletteController, :latest_wins
    get "/roulette/price", RouletteController, :price
    get "/store/redeem/:id", DeliverRedeemableController, :show
    get "/roulette/redeem/:id", DeliverPrizeController, :show

    post "/roulette", RouletteController, :spin
    post "/give_bonus/:id", BonusController, :give_bonus
    post "/spotlight", SpotlightController, :create
    post "/store/redeem", DeliverRedeemableController, :create
    post "/roulette/redeem", DeliverPrizeController, :create

    delete "/roulette/redeem/:badge_id/:user_id", DeliverPrizeController, :delete

    resources "/badges", BadgeController, only: [:index, :show]
    resources "/attendees", AttendeeController, except: [:create]
    resources "/referrals", ReferralController, only: [:create]
    resources "/companies", CompanyController, only: [:index, :show]
    resources "/redeems", RedeemController, only: [:create]
    resources "/store", RedeemableController, only: [:index, :show]
    resources "/association", DiscordAssociationController, only: [:show, :create]
    resources "/store/buy", BuyController, only: [:create]
    resources "/roulette/prizes", PrizeController, only: [:index, :show]

    get "/company/attendees/:id", CompanyController, :company_attendees
    get "/company/attendees/cvs/:id", CVController, :company_cvs
  end

  scope "/" do
    pipe_through :browser

    pow_session_routes()
  end

  # scope "/", Pow.Phoenix, as: "pow" do
  #  pipe_through [:browser, :protected]
  #  resources "/registration", RegistrationController, singleton: true, only: [:edit, :update]
  # end

  scope "/admin", SafiraWeb.Admin, as: :admin do
    pipe_through [:browser, :protected]

    resources "/badges", BadgeController
    resources "/attendees", AttendeeController
    resources "/staffs", StaffController
    resources "/companies", CompanyController
    resources "/redeems", RedeemController
    resources "/referrals", ReferralController
  end
end
