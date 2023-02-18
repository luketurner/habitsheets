defmodule HabitsheetWeb.SheetLive.SheetReviewSettings do
  use HabitsheetWeb, :live_component

  alias Habitsheet.Sheets

  @impl true
  def update(%{sheet: sheet} = assigns, socket) do

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Sheets.change_sheet(sheet))}
  end

  @impl true
  def handle_event("validate", %{"sheet" => sheet_params}, socket) do
    changeset =
      socket.assigns.sheet
      |> Sheets.change_sheet(sheet_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"sheet" => sheet_params}, socket) do
    case Sheets.update_sheet(socket.assigns.current_user.id, socket.assigns.sheet, sheet_params) do
      {:ok, sheet} ->
        {:noreply,
         socket
         |> assign(:sheet, sheet)
         |> put_flash(:info, "Sheet updated")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

end
