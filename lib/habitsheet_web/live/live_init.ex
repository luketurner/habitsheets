defmodule HabitsheetWeb.LiveInit do
  import Phoenix.LiveView
  import Phoenix.Component
  import HabitsheetWeb.LiveHelpers

  alias HabitsheetWeb.Router.Helpers, as: Routes

  def on_mount(:default, params, session, socket) do
    socket =
      socket
      |> assign_user_for_session(session)
      |> assign_viewport()
      |> assign_timezone()

    with {:ok, resources} <- get_resources_for_params(socket, params) do
      {:cont,
       socket
       |> assign(resources)}
    else
      _ ->
        {:halt,
         socket
         |> put_flash(:error, "Error loading resources.")
         |> redirect(to: Routes.home_path(socket, :index))}
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
