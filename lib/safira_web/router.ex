defmodule SafiraWeb.Router do
  use SafiraWeb, :router

  import SafiraWeb.UserAuth
  import SafiraWeb.UserRoles

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

  scope "/", SafiraWeb do
    pipe_through :browser

    get "/", PageController, :home
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

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SafiraWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SafiraWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SafiraWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/scanner", ScannerLive.Index, :index

      scope "/app", App do
        pipe_through [:require_attendee_user, :require_credential]
        live "/", HomeLive.Index, :index

        scope "/store", StoreLive do
          live "/", Index, :index
          live "/product/:id", Show, :show
        end

        scope "/credential", CredentialLive do
          live "/", Index, :index
          live "/:id", Show, :show
          live "/:id/edit", Edit, :edit
        end

        live "/vault", VaultLive.Index, :index
      end

      scope "/dashboard", Backoffice do
        pipe_through :require_staff_user

        scope "/attendees", AttendeeLive do
          live "/", Index, :index
          live "/:id", Show, :show
        end

        live "/staffs", StaffLive.Index, :index

        scope "/store/products", ProductLive do
          live "/", Index, :index
          live "/new", Index, :new
          live "/:id/edit", Index, :edit

          live "/:id", Show, :show
          live "/:id/show/edit", Show, :edit
        end

        scope "/badges", BadgeLive do
          live "/", Index, :index
          live "/new", Index, :new

          scope "/:id" do
            live "/edit", Index, :edit

            live "/conditions", Index, :conditions
            live "/conditions/new", Index, :conditions_new
            live "/conditions/:condition_id/edit", Index, :conditions_edit
          end

          scope "/categories" do
            live "/", Index, :categories
            live "/new", Index, :categories_new
            live "/:id/edit", Index, :categories_edit
          end
        end
      end
    end
  end

  scope "/", SafiraWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SafiraWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
