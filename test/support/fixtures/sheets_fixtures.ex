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

  @doc """
  Generate a habit.
  """
  def habit_fixture(attrs \\ %{}) do
    {:ok, habit} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Habitsheet.Sheets.create_habit()

    habit
  end
end
