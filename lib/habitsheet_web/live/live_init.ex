defmodule HabitsheetWeb.LiveInit do

  import Phoenix.LiveView
  import Phoenix.Component

  alias Habitsheet.Users
  alias Habitsheet.Sheets

  def on_mount(:default, _params, %{"user_token" => user_token}, socket) do
    {:cont, assign(socket, :current_user, Users.get_user_by_session_token(user_token))}
  end

  def on_mount(:require_authenticated_user, _params, _session, %{assigns: %{current_user: current_user}} = socket) do
    if current_user do
      if !Application.get_env(:habitsheet, :require_email_verification) || current_user.confirmed_at do
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

  def on_mount(:load_sheet, %{"sheet_id" => sheet_id}, _session, %{assigns: %{current_user: current_user}} = socket) do
    case Sheets.get_sheet_as(current_user, sheet_id) do
      {:ok, sheet} -> {:cont, assign(socket, :sheet, sheet)}
      {:error, _} ->
        {:halt,
         socket
         |> put_flash(:error, "Cannot find sheet.")
         |> redirect(to: HabitsheetWeb.Router.Helpers.sheet_index_path(socket, :index))}
    end
  end

  def on_mount(:load_shared_sheet, %{"share_id" => share_id}, _session, %{assigns: %{current_user: current_user}} = socket) do
    case Sheets.get_sheet_by_share_id_as(current_user, share_id) do
      {:ok, sheet} -> {:cont, assign(socket, :sheet, sheet)}
      {:error, _} ->
        {:halt,
         socket
         |> put_flash(:error, "Cannot find sheet.")
         |> redirect(to: HabitsheetWeb.Router.Helpers.home_path(socket, :index))}
    end
  end

end
