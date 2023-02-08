defmodule HabitsheetWeb.HabitControllerTest do
  use HabitsheetWeb.ConnCase

  import Habitsheet.SheetsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all habits", %{conn: conn} do
      conn = get(conn, Routes.habit_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Habits"
    end
  end

  describe "new habit" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.habit_path(conn, :new))
      assert html_response(conn, 200) =~ "New Habit"
    end
  end

  describe "create habit" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.habit_path(conn, :create), habit: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.habit_path(conn, :show, id)

      conn = get(conn, Routes.habit_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Habit"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.habit_path(conn, :create), habit: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Habit"
    end
  end

  describe "edit habit" do
    setup [:create_habit]

    test "renders form for editing chosen habit", %{conn: conn, habit: habit} do
      conn = get(conn, Routes.habit_path(conn, :edit, habit))
      assert html_response(conn, 200) =~ "Edit Habit"
    end
  end

  describe "update habit" do
    setup [:create_habit]

    test "redirects when data is valid", %{conn: conn, habit: habit} do
      conn = put(conn, Routes.habit_path(conn, :update, habit), habit: @update_attrs)
      assert redirected_to(conn) == Routes.habit_path(conn, :show, habit)

      conn = get(conn, Routes.habit_path(conn, :show, habit))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, habit: habit} do
      conn = put(conn, Routes.habit_path(conn, :update, habit), habit: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Habit"
    end
  end

  describe "delete habit" do
    setup [:create_habit]

    test "deletes chosen habit", %{conn: conn, habit: habit} do
      conn = delete(conn, Routes.habit_path(conn, :delete, habit))
      assert redirected_to(conn) == Routes.habit_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.habit_path(conn, :show, habit))
      end
    end
  end

  defp create_habit(_) do
    habit = habit_fixture()
    %{habit: habit}
  end
end
