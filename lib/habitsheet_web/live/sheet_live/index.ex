defmodule HabitsheetWeb.SheetLive.Index do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Sheet

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:sheets, list_sheets(socket.assigns.current_user.id))
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New sheet...")
    |> assign(:sheet, %Sheet{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All sheets")
    |> assign(:sheet, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Sheets.delete_sheet_by_id!(socket.assigns.current_user.id, id)

    {:noreply, assign(socket, :sheets, list_sheets(socket.assigns.current_user.id))}
  end

  defp list_sheets(current_user_id) do
    Sheets.list_sheets(current_user_id)
  end
end
