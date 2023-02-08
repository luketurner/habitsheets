defmodule Habitsheet.SheetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habitsheet.Sheets` context.
  """

  @doc """
  Generate a sheet.
  """
  def sheet_fixture(attrs \\ %{}) do
    {:ok, sheet} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Habitsheet.Sheets.create_sheet()

    sheet
  end
end
