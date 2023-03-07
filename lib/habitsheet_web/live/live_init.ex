defmodule HabitsheetWeb.LiveInit do
  import Phoenix.LiveView
  import HabitsheetWeb.LiveHelpers

  alias HabitsheetWeb.Router.Helpers, as: Routes

  def on_mount(:default, params, session, socket) do
    socket =
      socket
      |> assign_user_for_session(session)
      |> assign_browser_params()

    socket =
      if params["date"] do
        assign_date(socket, params["date"])
      else
        socket
      end

    {:cont, socket}
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
