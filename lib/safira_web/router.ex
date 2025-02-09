defmodule SafiraWeb.Router do
  use SafiraWeb, :router

  import SafiraWeb.UserAuth
  import SafiraWeb.UserRoles
  import SafiraWeb.EventRoles

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SafiraWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Landing
  scope "/", SafiraWeb.Landing do
    pipe_through :browser

    live_session :default, on_mount: [{SafiraWeb.UserAuth, :mount_current_user}] do
      live "/", HomeLive.Index, :index
      live "/faqs", FAQLive.Index, :index
      live "/team", TeamLive.Index, :index
      live "/schedule", ScheduleLive.Index, :index
      live "/challenges", ChallengesLive.Index, :index
      live "/speakers", SpeakersLive.Index, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SafiraWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:safira, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SafiraWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SafiraWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    post "/users/log_in", UserSessionController, :create

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SafiraWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new

      pipe_through :registrations_open
      live "/users/register", UserRegistrationLive, :new
      post "/users/register", UserSessionController, :new
    end
  end

  scope "/", SafiraWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {SafiraWeb.UserAuth, :ensure_authenticated},
        {SafiraWeb.Spotlight, :fetch_current_spotlight}
      ] do
      live "/users/confirmation_pending", ConfirmationPendingLive, :index

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      scope "/app", App do
        pipe_through [:require_attendee_user]

        live "/waiting", WaitingLive.Index, :index

        pipe_through [:backoffice_enabled]

        scope "/credential", CredentialLive do
          pipe_through [:require_no_credential]
          live "/link", Edit, :edit
        end

        pipe_through [:require_credential]

        live "/", HomeLive.Index, :index
        live "/edit", HomeLive.Index, :edit

        live "/credential", CredentialLive.Index, :index

        live "/wheel", WheelLive.Index, :index

        live "/coin_flip", CoinFlipLive.Index, :index

        scope "/badges", BadgeLive do
          live "/", Index, :index
          live "/:id", Show, :show
        end

        scope "/slots", SlotsLive do
          live "/", Index, :index
          live "/paytable", Index, :show_paytable
        end

        scope "/store", StoreLive do
          live "/", Index, :index
          live "/product/:id", Show, :show
        end

        live "/vault", VaultLive.Index, :index
      end

      scope "/downloads" do
        scope "/" do
          pipe_through [:require_staff_user]
          get "/attendees", DownloadController, :attendees_data
          post "/qr_codes", DownloadController, :generate_credentials
          get "/cv_challenge", DownloadController, :cv_challenge
        end

        scope "/" do
          pipe_through [:require_company_user]
          get "/cvs", DownloadController, :cvs
        end
      end

      scope "/sponsor", Sponsor do
        pipe_through :require_company_user

        live "/", HomeLive.Index, :index
        live "/scanner", ScannerLive.Index, :index
      end

      scope "/dashboard", Backoffice do
        pipe_through [:require_staff_user]

        scope "/spotlights", SpotlightLive do
          live "/", Index, :index
          live "/new", Index, :new
          live "/new/:id", Index, :confirm
          live "/config", Index, :config

          scope "/config" do
            live "/tiers", Index, :tiers
            live "/tiers/:id/edit", Index, :tiers_edit
          end
        end

        scope "/attendees", AttendeeLive do
          live "/", Index, :index
          live "/:id", Show, :show
          live "/:id/edit/tokens", Show, :tokens_edit
        end

        scope "/event", EventLive do
          live "/", Index, :index
          live "/edit", Index, :edit
          live "/credentials", Index, :credentials

          scope "/faqs" do
            live "/", Index, :faqs
            live "/new", Index, :faqs_new
            live "/:id/edit", Index, :faqs_edit
          end

          scope "/teams" do
            live "/", Index, :teams
            live "/new", Index, :teams_new

            scope "/:team_id/edit" do
              live "/", Index, :teams_edit
              live "/members", Index, :teams_members
              live "/members/:id", Index, :teams_members_edit
            end
          end
        end

        scope "/staffs", StaffLive do
          live "/", Index, :index
          live "/new", Index, :new

          live "/:id/edit", Index, :edit

          scope "/roles" do
            live "/", Index, :roles
            live "/new", Index, :roles_new
            live "/:id/edit", Index, :roles_edit
          end
        end

        scope "/companies", CompanyLive do
          live "/", Index, :index
          live "/new", Index, :new

          live "/:id/edit", Index, :edit

          scope "/tiers" do
            live "/", Index, :tiers
            live "/new", Index, :tiers_new
            live "/:id/edit", Index, :tiers_edit
          end
        end

        scope "/schedule", ScheduleLive do
          live "/edit", Index, :edit_schedule

          scope "/activities" do
            live "/", Index, :index
            live "/new", Index, :new
            live "/:id/edit", Index, :edit
            live "/:id/enrolments", Index, :enrolments

            scope "/speakers" do
              live "/", Index, :speakers
              live "/new", Index, :speakers_new
              live "/:id/edit", Index, :speakers_edit
            end

            scope "/categories" do
              live "/", Index, :categories
              live "/new", Index, :categories_new
              live "/:id/edit", Index, :categories_edit
            end
          end
        end

        scope "/store/products", ProductLive do
          live "/", Index, :index
          live "/new", Index, :new
          live "/:id/edit", Index, :edit

          scope "/purchases", PurchaseLive do
            live "/", Index, :show
            live "/:id/redeemed", Index, :redeem
            live "/:id/refund", Index, :refund
          end

          live "/:id", Show, :show
          live "/:id/show/edit", Show, :edit
        end

        scope "/badges", BadgeLive do
          live "/", Index, :index
          live "/new", Index, :new
          live "/import", Index, :import

          scope "/:id" do
            live "/edit", Index, :edit

            scope "/conditions" do
              live "/", Index, :conditions
              live "/new", Index, :conditions_new
              live "/:condition_id/edit", Index, :conditions_edit
            end

            scope "/triggers" do
              live "/", Index, :triggers
              live "/new", Index, :triggers_new
              live "/:trigger_id/edit", Index, :triggers_edit
            end
          end

          scope "/categories" do
            live "/", Index, :categories
            live "/new", Index, :categories_new
            live "/:id/edit", Index, :categories_edit
          end
        end

        scope "/minigames" do
          scope "/prizes", PrizeLive do
            live "/", Index, :index
            live "/new", Index, :new

            scope "/:id" do
              live "/edit", Index, :edit
            end
          end

          scope "/challenges", ChallengeLive do
            live "/", Index, :index
            live "/new", Index, :new

            scope "/:id" do
              live "/edit", Index, :edit
            end
          end

          scope "/wheel" do
            live "/", MinigamesLive.Index, :edit_wheel
            live "/drops", MinigamesLive.Index, :edit_wheel_drops
            live "/simulator", MinigamesLive.Index, :simulate_wheel
          end

          scope "/slots" do
            live "/", MinigamesLive.Index, :edit_slots
            live "/reels_icons", MinigamesLive.Index, :edit_slots_reel_icons_icons
            live "/reels_position", MinigamesLive.Index, :edit_slots_reel_icons_position
            live "/paytable", MinigamesLive.Index, :edit_slots_paytable
            live "/payline", MinigamesLive.Index, :edit_slots_payline
          end

          live "/", MinigamesLive.Index, :index

          live "/coin_flip", MinigamesLive.Index, :edit_coin_flip
        end

        scope "/scanner", ScannerLive do
          live "/", Index, :index

          scope "/badge", BadgeLive do
            live "/:id/give", Index, :edit
          end
        end
      end
    end
  end

  scope "/", SafiraWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live "/users/reset_password/:token", UserResetPasswordLive, :edit

    live_session :current_user,
      on_mount: [{SafiraWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
