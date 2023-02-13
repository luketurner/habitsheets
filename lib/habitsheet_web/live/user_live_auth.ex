defmodule HabitsheetWeb.UserLiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Habitsheet.Users

  def on_mount(:default, _params, %{"user_token" => user_token}, socket) do
    socket = assign_new(socket, :current_user, fn ->
      Users.get_user_by_session_token(user_token)
    end)
    if socket.assigns.current_user.id do
      {:cont, socket}
    else
      {:halt,
       socket
       |> put_flash(:error, "Please login to view this page.")
       |> redirect(to: HabitsheetWeb.Router.Helpers.user_session_path(socket, :new))}
    end
  end

end
