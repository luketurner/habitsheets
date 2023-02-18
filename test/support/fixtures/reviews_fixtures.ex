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

  @doc """
  Generate a daily_review_email.
  """
  def daily_review_email_fixture(attrs \\ %{}) do
    {:ok, daily_review_email} =
      attrs
      |> Enum.into(%{
        address: "some address",
        retry_num: 42,
        status: :success,
        trigger: :fill_review
      })
      |> Habitsheet.Reviews.create_daily_review_email()

    daily_review_email
  end
end
