defmodule HabitsheetWeb.SheetLive.SheetEditor do
  use HabitsheetWeb, :live_component

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Sheet

  @impl true
  def update(%{sheet: sheet} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Sheets.sheet_update_changeset(sheet))}
  end

  @impl true
  def update(%{action: :new} = assigns, socket) do
    new_sheet = %Sheet{}
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:sheet, new_sheet)
     |> assign(:changeset, Sheets.sheet_create_changeset(new_sheet))}
  end

  @impl true
  def handle_event("validate", %{"sheet" => sheet_params}, socket) do
    changeset = if socket.assigns.action == :new do
      Sheets.sheet_create_changeset(socket.assigns.sheet, sheet_params)
    else
      Sheets.sheet_update_changeset(socket.assigns.sheet, sheet_params)
    end
    changeset = Map.put(changeset, :action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"sheet" => sheet_params}, socket) do
    save_sheet(socket, socket.assigns.action, sheet_params)
  end

  defp save_sheet(socket, :edit, sheet_params) do
    sheet = socket.assigns.sheet
    with(
      :ok <- Bodyguard.permit(Sheets, :update_sheet, socket.assigns.current_user, sheet),
      changeset <- Sheets.sheet_update_changeset(socket.assigns.sheet, sheet_params),
      {:ok, sheet} <- Sheets.update_sheet(changeset)
    ) do
      {:noreply,
         socket
         |> assign(:sheet, sheet)
         |> put_flash(:info, "Sheet updated")
         |> push_redirect(to: socket.assigns.return_to)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:submit_error, "Error updating sheet")
         |> assign(:changeset, changeset)}
      {:error, _} ->
        {:noreply,
         socket
         |> assign(:submit_error, "Error updating sheet")}
    end
  end

  defp save_sheet(socket, :new, sheet_params) do
    sheet_params = Map.put(sheet_params, "user_id", socket.assigns.current_user.id)
    with(
      changeset <- Sheets.sheet_create_changeset(socket.assigns.sheet, sheet_params),
      :ok <- Bodyguard.permit(Sheets, :create_sheet, socket.assigns.current_user, changeset),
      {:ok, sheet} <- Sheets.create_sheet(changeset)
    ) do
      {:noreply,
         socket
         |> assign(:sheet, sheet)
         |> put_flash(:info, "Sheet created")
         |> push_redirect(to: socket.assigns.return_to)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:submit_error, "Error creating sheet")
         |> assign(:changeset, changeset)}
      {:error, v} ->
        {:noreply,
         socket
         |> assign(:submit_error, "Error creating sheet: #{v}")}
    end
  end
end
