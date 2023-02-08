defmodule Habitsheet.SheetsTest do
  use Habitsheet.DataCase

  alias Habitsheet.Sheets

  describe "sheets" do
    alias Habitsheet.Sheets.Sheet

    import Habitsheet.SheetsFixtures

    @invalid_attrs %{title: nil}

    test "list_sheets/0 returns all sheets" do
      sheet = sheet_fixture()
      assert Sheets.list_sheets() == [sheet]
    end

    test "get_sheet!/1 returns the sheet with given id" do
      sheet = sheet_fixture()
      assert Sheets.get_sheet!(sheet.id) == sheet
    end

    test "create_sheet/1 with valid data creates a sheet" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Sheet{} = sheet} = Sheets.create_sheet(valid_attrs)
      assert sheet.title == "some title"
    end

    test "create_sheet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sheets.create_sheet(@invalid_attrs)
    end

    test "update_sheet/2 with valid data updates the sheet" do
      sheet = sheet_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Sheet{} = sheet} = Sheets.update_sheet(sheet, update_attrs)
      assert sheet.title == "some updated title"
    end

    test "update_sheet/2 with invalid data returns error changeset" do
      sheet = sheet_fixture()
      assert {:error, %Ecto.Changeset{}} = Sheets.update_sheet(sheet, @invalid_attrs)
      assert sheet == Sheets.get_sheet!(sheet.id)
    end

    test "delete_sheet/1 deletes the sheet" do
      sheet = sheet_fixture()
      assert {:ok, %Sheet{}} = Sheets.delete_sheet(sheet)
      assert_raise Ecto.NoResultsError, fn -> Sheets.get_sheet!(sheet.id) end
    end

    test "change_sheet/1 returns a sheet changeset" do
      sheet = sheet_fixture()
      assert %Ecto.Changeset{} = Sheets.change_sheet(sheet)
    end
  end
end
