defmodule HabitsheetWeb.OwnedSheetLiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Habitsheet.Sheets

  def on_mount(:default, %{"id" => id}, _session, socket) do
    user_id = socket.assigns.current_user.id

    socket = try do
      assign_new(socket, :sheet, fn ->
        Sheets.get_sheet!(user_id, id)
      end)
    rescue
      Ecto.NoResultsError -> socket
    end

    if Map.has_key?(socket.assigns, :sheet) && socket.assigns.sheet.id do
      {:cont, socket}
    else
      {:halt,
       socket
       |> put_flash(:error, "Cannot find sheet.")
       |> redirect(to: HabitsheetWeb.Router.Helpers.sheet_index_path(socket, :index))}
    end
  end

end
