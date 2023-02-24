defmodule HabitsheetWeb.SheetLive.Index do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Sheet

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign_sheets()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New sheet")
    |> assign(:sheet, %Sheet{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All sheets")
    |> assign(:sheet, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sheet = Enum.find(socket.assigns.sheets, fn sheet -> sheet.id == id end)
    {:noreply, case Sheets.delete_sheet_as(socket.assigns.current_user, sheet) do
      {:ok, _sheet} -> assign_sheets(socket)
      {:error, _error} ->
        socket
        |> put_flash(:error, "Cannot delete sheet")
        |> push_redirect(to: Routes.sheet_index_path(socket, :index))
    end}
  end

  defp assign_sheets(socket) do
    current_user = socket.assigns.current_user
    case Sheets.list_sheets_for_user_as(current_user, current_user) do
      {:ok, sheets} -> assign(socket, :sheets, sheets)
      {:error, _error} ->
        socket
        |> put_flash(:error, "Error viewing sheets")
        |> push_redirect(to: Routes.home_path(socket, :index))
    end
  end
end
