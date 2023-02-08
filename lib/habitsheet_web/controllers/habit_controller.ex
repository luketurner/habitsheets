defmodule HabitsheetWeb.HabitController do
  use HabitsheetWeb, :controller

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Habit

  def index(conn, _params) do
    habits = Sheets.list_habits()
    render(conn, "index.html", habits: habits)
  end

  def new(conn, _params) do
    changeset = Sheets.change_habit(%Habit{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"habit" => habit_params}) do
    case Sheets.create_habit(habit_params) do
      {:ok, habit} ->
        conn
        |> put_flash(:info, "Habit created successfully.")
        |> redirect(to: Routes.habit_path(conn, :show, habit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    habit = Sheets.get_habit!(id)
    render(conn, "show.html", habit: habit)
  end

  def edit(conn, %{"id" => id}) do
    habit = Sheets.get_habit!(id)
    changeset = Sheets.change_habit(habit)
    render(conn, "edit.html", habit: habit, changeset: changeset)
  end

  def update(conn, %{"id" => id, "habit" => habit_params}) do
    habit = Sheets.get_habit!(id)

    case Sheets.update_habit(habit, habit_params) do
      {:ok, habit} ->
        conn
        |> put_flash(:info, "Habit updated successfully.")
        |> redirect(to: Routes.habit_path(conn, :show, habit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", habit: habit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    habit = Sheets.get_habit!(id)
    {:ok, _habit} = Sheets.delete_habit(habit)

    conn
    |> put_flash(:info, "Habit deleted successfully.")
    |> redirect(to: Routes.habit_path(conn, :index))
  end
end
