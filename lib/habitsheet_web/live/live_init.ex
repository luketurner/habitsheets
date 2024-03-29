defmodule HabitsheetWeb.LiveInit do
  import Phoenix.LiveView
  import HabitsheetWeb.LiveHelpers
  import Phoenix.Component

  alias HabitsheetWeb.Router.Helpers, as: Routes
  alias Habitsheet.DateHelpers

  def on_mount(:default, params, session, socket) do
    socket =
      socket
      |> assign_user_for_session(session)
      |> assign_browser_params()
      |> assign_color_scheme()
      |> assign_theme()
      |> assign(:manpage, params["manpage"])

    socket =
      if params["date"] do
        assign_date(socket, params["date"])
      else
        socket
      end

    if params["date"] != "today" && Map.has_key?(socket.assigns, :date) &&
        DateHelpers.today?(socket.assigns.date, Map.get(socket.assigns, :timezone, "Etc/UTC")) do
      {:halt, socket |> push_navigate(to: Routes.daily_view_path(socket, :index, "today"))}
    else
      {:cont, socket}
    end
  end

  def on_mount(
        :require_authenticated_user,
        _params,
        _session,
        %{assigns: %{current_user: current_user}} = socket
      ) do
    if current_user do
      if !Application.get_env(:habitsheet, :require_email_verification) ||
           current_user.confirmed_at do
        {:cont, socket}
      else
        {:halt,
         socket
         |> put_flash(
           :error,
           "Please click the link in the verification email to activate your account."
         )
         |> redirect(to: Routes.user_confirmation_path(socket, :new))}
      end
    else
      {:halt,
       socket
       |> put_flash(:error, "Please login to view this page.")
       |> redirect(to: Routes.user_session_path(socket, :new))}
    end
  end
end
