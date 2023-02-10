defmodule HabitsheetWeb.HabitStatisticLiveTest do
  use HabitsheetWeb.ConnCase

  import Phoenix.LiveViewTest
  import Habitsheet.StatisticsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_habit_statistic(_) do
    habit_statistic = habit_statistic_fixture()
    %{habit_statistic: habit_statistic}
  end

  describe "Index" do
    setup [:create_habit_statistic]

    test "lists all habit_statistics", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.habit_statistic_index_path(conn, :index))

      assert html =~ "Listing Habit statistics"
    end

    test "saves new habit_statistic", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.habit_statistic_index_path(conn, :index))

      assert index_live |> element("a", "New Habit statistic") |> render_click() =~
               "New Habit statistic"

      assert_patch(index_live, Routes.habit_statistic_index_path(conn, :new))

      assert index_live
             |> form("#habit_statistic-form", habit_statistic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#habit_statistic-form", habit_statistic: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.habit_statistic_index_path(conn, :index))

      assert html =~ "Habit statistic created successfully"
    end

    test "updates habit_statistic in listing", %{conn: conn, habit_statistic: habit_statistic} do
      {:ok, index_live, _html} = live(conn, Routes.habit_statistic_index_path(conn, :index))

      assert index_live |> element("#habit_statistic-#{habit_statistic.id} a", "Edit") |> render_click() =~
               "Edit Habit statistic"

      assert_patch(index_live, Routes.habit_statistic_index_path(conn, :edit, habit_statistic))

      assert index_live
             |> form("#habit_statistic-form", habit_statistic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#habit_statistic-form", habit_statistic: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.habit_statistic_index_path(conn, :index))

      assert html =~ "Habit statistic updated successfully"
    end

    test "deletes habit_statistic in listing", %{conn: conn, habit_statistic: habit_statistic} do
      {:ok, index_live, _html} = live(conn, Routes.habit_statistic_index_path(conn, :index))

      assert index_live |> element("#habit_statistic-#{habit_statistic.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#habit_statistic-#{habit_statistic.id}")
    end
  end

  describe "Show" do
    setup [:create_habit_statistic]

    test "displays habit_statistic", %{conn: conn, habit_statistic: habit_statistic} do
      {:ok, _show_live, html} = live(conn, Routes.habit_statistic_show_path(conn, :show, habit_statistic))

      assert html =~ "Show Habit statistic"
    end

    test "updates habit_statistic within modal", %{conn: conn, habit_statistic: habit_statistic} do
      {:ok, show_live, _html} = live(conn, Routes.habit_statistic_show_path(conn, :show, habit_statistic))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Habit statistic"

      assert_patch(show_live, Routes.habit_statistic_show_path(conn, :edit, habit_statistic))

      assert show_live
             |> form("#habit_statistic-form", habit_statistic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#habit_statistic-form", habit_statistic: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.habit_statistic_show_path(conn, :show, habit_statistic))

      assert html =~ "Habit statistic updated successfully"
    end
  end
end
