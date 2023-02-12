defmodule HabitsheetWeb.UserLiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Habitsheet.Users

  def on_mount(:default, _params, session, socket) do
    if current_user = Users.get_user_by_session_token(session["user_token"]) do
      {:cont, assign(socket, :current_user, current_user)}
    else
      {:halt}
    end
  end

end
