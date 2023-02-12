defmodule HabitsheetWeb.Router do
  use HabitsheetWeb, :router

  import HabitsheetWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HabitsheetWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HabitsheetWeb do
    pipe_through :browser

    get "/", HomeController, :index

    scope "/sheets" do

      live_session :user, on_mount: HabitsheetWeb.UserLiveAuth do
        pipe_through :require_authenticated_user
        live "/", SheetLive.Index, :index
        live "/new", SheetLive.Index, :new
        live "/:id/edit", SheetLive.Index, :edit

        live "/:id", SheetLive.Show, :show
        live "/:id/habits/new", SheetLive.Show, :new_habit
        live "/:id/habits/:habit_id/edit", SheetLive.Show, :edit_habit
      end


    end

  end

  # defp fetch_current_user(conn, _opts) do
  #   if user_id = get_session(conn, :user_id) do
  #     assign(conn, :user_id, user_id)
  #   else
  #     temp_id = Ecto.UUID.generate()
  #     conn
  #     |> assign(:user_id, temp_id)
  #     |> put_session(:user_id, temp_id)
  #   end
  # end

  # Other scopes may use custom stacks.
  # scope "/api", HabitsheetWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HabitsheetWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", HabitsheetWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", HabitsheetWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", HabitsheetWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
