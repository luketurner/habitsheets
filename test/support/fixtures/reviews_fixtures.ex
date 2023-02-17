defmodule Habitsheet.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habitsheet.Reviews` context.
  """

  @doc """
  Generate a daily_review.
  """
  def daily_review_fixture(attrs \\ %{}) do
    {:ok, daily_review} =
      attrs
      |> Enum.into(%{
        date: ~D[2023-02-15],
        notes: "some notes",
        status: :started
      })
      |> Habitsheet.Reviews.create_daily_review()

    daily_review
  end
end
