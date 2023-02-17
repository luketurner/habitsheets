defmodule Habitsheet.ReviewsTest do
  use Habitsheet.DataCase

  alias Habitsheet.Reviews

  describe "daily_review" do
    alias Habitsheet.Reviews.DailyReview

    import Habitsheet.ReviewsFixtures

    @invalid_attrs %{date: nil, notes: nil, status: nil}

    test "list_daily_review/0 returns all daily_review" do
      daily_review = daily_review_fixture()
      assert Reviews.list_daily_review() == [daily_review]
    end

    test "get_daily_review!/1 returns the daily_review with given id" do
      daily_review = daily_review_fixture()
      assert Reviews.get_daily_review!(daily_review.id) == daily_review
    end

    test "create_daily_review/1 with valid data creates a daily_review" do
      valid_attrs = %{date: ~D[2023-02-15], notes: "some notes", status: :started}

      assert {:ok, %DailyReview{} = daily_review} = Reviews.create_daily_review(valid_attrs)
      assert daily_review.date == ~D[2023-02-15]
      assert daily_review.notes == "some notes"
      assert daily_review.status == :started
    end

    test "create_daily_review/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reviews.create_daily_review(@invalid_attrs)
    end

    test "update_daily_review/2 with valid data updates the daily_review" do
      daily_review = daily_review_fixture()
      update_attrs = %{date: ~D[2023-02-16], notes: "some updated notes", status: :finished}

      assert {:ok, %DailyReview{} = daily_review} = Reviews.update_daily_review(daily_review, update_attrs)
      assert daily_review.date == ~D[2023-02-16]
      assert daily_review.notes == "some updated notes"
      assert daily_review.status == :finished
    end

    test "update_daily_review/2 with invalid data returns error changeset" do
      daily_review = daily_review_fixture()
      assert {:error, %Ecto.Changeset{}} = Reviews.update_daily_review(daily_review, @invalid_attrs)
      assert daily_review == Reviews.get_daily_review!(daily_review.id)
    end

    test "delete_daily_review/1 deletes the daily_review" do
      daily_review = daily_review_fixture()
      assert {:ok, %DailyReview{}} = Reviews.delete_daily_review(daily_review)
      assert_raise Ecto.NoResultsError, fn -> Reviews.get_daily_review!(daily_review.id) end
    end

    test "change_daily_review/1 returns a daily_review changeset" do
      daily_review = daily_review_fixture()
      assert %Ecto.Changeset{} = Reviews.change_daily_review(daily_review)
    end
  end
end
