defmodule HabitsheetWeb.Router do
  use HabitsheetWeb, :router

  import HabitsheetWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :fetch_query_params
    plug :assign_manpage
    plug :put_root_layout, {HabitsheetWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :assign_user_theme
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HabitsheetWeb do
    pipe_through :browser

    get "/", HomeController, :index

    scope "/" do
      live_session :user,
        on_mount: [HabitsheetWeb.LiveInit, {HabitsheetWeb.LiveInit, :require_authenticated_user}] do
        pipe_through :require_authenticated_user

        scope "/habits" do
          live "/", Live.HabitList, :index
          live "/archived", Live.HabitList, :archived
          live "/add", Live.HabitEditor, :new
          live "/:habit_id/edit", Live.HabitEditor, :edit
        end

        scope "/tasks" do
          live "/", Live.TaskList, :index
          live "/done", Live.TaskList, :completed
          live "/archived", Live.TaskList, :archived
          live "/add", Live.TaskEditor, :new
          live "/:task_id/edit", Live.TaskEditor, :edit
        end

        live "/:date", Live.DailyView, :index
        live "/:date/review", Live.DailyReview, :index
      end
    end
  end

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
    post "/users/delete", UserSettingsController, :delete
    post "/users/clear_data", UserSettingsController, :clear_data
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

  def assign_manpage(conn, _) do
    assign(conn, :manpage, Map.get(conn.query_params, "manpage"))
  end

  # TODO -- this doesn't do browser-based theme detection.
  def assign_user_theme(%{assigns: %{current_user: %{color_scheme: :dark}}} = conn, _) do
    assign(conn, :theme, HabitsheetWeb.LiveHelpers.theme_for_scheme(:dark))
  end

  def assign_user_theme(conn, _) do
    assign(conn, :theme, HabitsheetWeb.LiveHelpers.theme_for_scheme(:light))
  end
end
