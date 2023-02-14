defmodule HabitsheetWeb.UserLiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Habitsheet.Users

  def on_mount(:default, _params, %{"user_token" => user_token}, socket) do
    socket = assign_new(socket, :current_user, fn ->
      Users.get_user_by_session_token(user_token)
    end)
    if socket.assigns.current_user.id do
      if !require_email_verification?() || socket.assigns.current_user.confirmed_at do
        {:cont, socket}
      else
        {:halt,
         socket
         |> put_flash(:error, "Please click the link in the verification email to activate your account.")
         |> redirect(to: HabitsheetWeb.Router.Helpers.user_confirmation_path(socket, :new))}
      end
    else
      {:halt,
       socket
       |> put_flash(:error, "Please login to view this page.")
       |> redirect(to: HabitsheetWeb.Router.Helpers.user_session_path(socket, :new))}
    end
  end

  defp require_email_verification?(), do: Application.get_env(:habitsheet, :require_email_verification)
end
