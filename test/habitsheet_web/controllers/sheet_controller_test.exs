defmodule HabitsheetWeb.SheetControllerTest do
  use HabitsheetWeb.ConnCase

  import Habitsheet.SheetsFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  describe "index" do
    test "lists all sheets", %{conn: conn} do
      conn = get(conn, Routes.sheet_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Sheets"
    end
  end

  describe "new sheet" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.sheet_path(conn, :new))
      assert html_response(conn, 200) =~ "New Sheet"
    end
  end

  describe "create sheet" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.sheet_path(conn, :create), sheet: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.sheet_path(conn, :show, id)

      conn = get(conn, Routes.sheet_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Sheet"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.sheet_path(conn, :create), sheet: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Sheet"
    end
  end

  describe "edit sheet" do
    setup [:create_sheet]

    test "renders form for editing chosen sheet", %{conn: conn, sheet: sheet} do
      conn = get(conn, Routes.sheet_path(conn, :edit, sheet))
      assert html_response(conn, 200) =~ "Edit Sheet"
    end
  end

  describe "update sheet" do
    setup [:create_sheet]

    test "redirects when data is valid", %{conn: conn, sheet: sheet} do
      conn = put(conn, Routes.sheet_path(conn, :update, sheet), sheet: @update_attrs)
      assert redirected_to(conn) == Routes.sheet_path(conn, :show, sheet)

      conn = get(conn, Routes.sheet_path(conn, :show, sheet))
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, sheet: sheet} do
      conn = put(conn, Routes.sheet_path(conn, :update, sheet), sheet: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Sheet"
    end
  end

  describe "delete sheet" do
    setup [:create_sheet]

    test "deletes chosen sheet", %{conn: conn, sheet: sheet} do
      conn = delete(conn, Routes.sheet_path(conn, :delete, sheet))
      assert redirected_to(conn) == Routes.sheet_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.sheet_path(conn, :show, sheet))
      end
    end
  end

  defp create_sheet(_) do
    sheet = sheet_fixture()
    %{sheet: sheet}
  end
end
