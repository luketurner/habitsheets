defmodule HabitsheetWeb.HabitController do
  use HabitsheetWeb, :controller

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Habit

  def index(conn, %{"sheet_id" => sheet_id}) do
    habits = Sheets.list_habits(sheet_id)
    render(conn, "index.html", habits: habits, sheet_id: sheet_id)
  end

  def new(conn, %{"sheet_id" => sheet_id}) do
    changeset = Sheets.change_habit(%Habit{}, %{ sheet_id: sheet_id })
    render(conn, "new.html", changeset: changeset, sheet_id: sheet_id)
  end

  def create(conn, %{"habit" => habit_params, "sheet_id" => sheet_id}) do
    case Sheets.create_habit(Map.put(habit_params, "sheet_id", sheet_id)) do
      {:ok, habit} ->
        conn
        |> put_flash(:info, "Habit created successfully.")
        |> redirect(to: Routes.sheet_habit_path(conn, :show, habit.sheet_id, habit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, sheet_id: sheet_id)
    end
  end

  def show(conn, %{"id" => id, "sheet_id" => sheet_id}) do
    habit = Sheets.get_habit!(id)
    render(conn, "show.html", habit: habit, sheet_id: sheet_id)
  end

  def edit(conn, %{"id" => id, "sheet_id" => sheet_id}) do
    habit = Sheets.get_habit!(id)
    changeset = Sheets.change_habit(habit)
    render(conn, "edit.html", habit: habit, changeset: changeset, sheet_id: sheet_id)
  end

  def update(conn, %{"id" => id, "habit" => habit_params, "sheet_id" => sheet_id}) do
    habit = Sheets.get_habit!(id)

    case Sheets.update_habit(habit, habit_params) do
      {:ok, habit} ->
        conn
        |> put_flash(:info, "Habit updated successfully.")
        |> redirect(to: Routes.sheet_habit_path(conn, :show, habit.sheet_id, habit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", habit: habit, changeset: changeset, sheet_id: sheet_id)
    end
  end

  def delete(conn, %{"id" => id, "sheet_id" => sheet_id}) do
    habit = Sheets.get_habit!(id)
    {:ok, _habit} = Sheets.delete_habit(habit)

    conn
    |> put_flash(:info, "Habit deleted successfully.")
    |> redirect(to: Routes.sheet_habit_path(conn, :index, sheet_id))
  end
end
