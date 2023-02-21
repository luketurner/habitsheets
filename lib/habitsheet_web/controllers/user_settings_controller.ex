defmodule HabitsheetWeb.UserSettingsController do
  use HabitsheetWeb, :controller

  alias Habitsheet.Users
  alias HabitsheetWeb.UserAuth

  plug :assign_changesets

  def edit(conn, _params) do
    conn
    |> assign(:timezones, TzExtra.time_zone_identifiers())
    |> render("edit.html")
  end

  def delete(conn, _params) do
    case Users.delete_user(conn.assigns.current_user) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Deleted account #{conn.assigns.current_user.email}")
        |> redirect(to: Routes.home_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:error, "Error deleting account")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def clear_data(conn, _params) do
    case Users.clear_user_data(conn.assigns.current_user) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Cleared account data")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
      {:error, _} ->
        conn
        |> put_flash(:error, "Error clearing account data")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def update(conn, %{"action" => "update_settings", "user" => user_params} = params) do
    user = conn.assigns.current_user

    # TODO
    case Users.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", settings_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Users.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Users.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Users.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Users.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  defp assign_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:settings_changeset, Users.change_user(user))
    |> assign(:email_changeset, Users.change_user_email(user))
    |> assign(:password_changeset, Users.change_user_password(user))
  end
end
