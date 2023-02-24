defmodule HabitsheetWeb.SheetLive.SheetShare do
  use HabitsheetWeb, :live_component

  alias Habitsheet.Sheets

  @impl true
  def update(%{sheet: sheet} = assigns, socket) do

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:share_url, if(sheet.share_id, do: Routes.shared_sheet_show_url(socket, :show, sheet.share_id)))}
  end

  @impl true
  def handle_event("share", _params, socket) do
    case Sheets.share_sheet_as(socket.assigns.current_user, socket.assigns.sheet) do
      {:ok, _sheet} ->
        {:noreply, push_redirect(socket, Routes.sheet_show_path(socket, :share, socket.assigns.sheet.id))}
      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error sharing sheet")
         |> push_redirect(Routes.sheet_show_path(socket, :share, socket.assigns.sheet.id))}
    end
  end

  @impl true
  def handle_event("unshare", _params, socket) do
    case Sheets.unshare_sheet_as(socket.assigns.current_user, socket.assigns.sheet) do
      {:ok, _sheet} ->
        {:noreply, push_redirect(socket, Routes.sheet_show_path(socket, :share, socket.assigns.sheet.id))}
      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error unsharing sheet")
         |> push_redirect(Routes.sheet_show_path(socket, :share, socket.assigns.sheet.id))}
    end
  end

  @impl true
  def handle_event("close", _params, socket) do
    {:noreply, push_redirect(socket, to: socket.assigns.return_to)}
  end

end
