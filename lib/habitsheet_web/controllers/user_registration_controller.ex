defmodule HabitsheetWeb.UserRegistrationController do
  use HabitsheetWeb, :controller

  alias Habitsheet.Users
  alias Habitsheet.Users.User
  alias HabitsheetWeb.UserAuth

  def new(conn, _params) do
    # TODO -- browser timezone detection won't work unless I convert this to a LiveView...
    default_timezone = get_in(conn.private, [:connect_params, "browser_timezone"]) || "Etc/UTC"
    changeset = Users.change_user_registration(%User{}, %{timezone: default_timezone})

    render(conn, "new.html", changeset: changeset, timezones: TzExtra.time_zone_identifiers())
  end

  def create(conn, %{"user" => user_params}) do
    case Users.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Users.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
