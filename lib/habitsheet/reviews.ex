defmodule Habitsheet.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Habitsheet.Repo

  alias Habitsheet.Reviews.DailyReview

  def get_or_create_daily_review_by_date(user_id, sheet_id, date) do
    Repo.insert(%DailyReview{
      user_id: user_id,
      sheet_id: sheet_id,
      date: date,
      status: :started
    },
    on_conflict: {:replace, [:updated_at]},
    conflict_target: [:user_id, :sheet_id, :date],
    returning: true)
  end

  @doc """
  Returns the list of daily_review.

  ## Examples

      iex> list_daily_review()
      [%DailyReview{}, ...]

  """
  def list_daily_review(user_id, sheet_id) do
    Repo.all(from r in DailyReview, select: r, where: r.user_id == ^user_id and r.sheet_id == ^sheet_id)
  end

  @doc """
  Gets a single daily_review.

  Raises `Ecto.NoResultsError` if the Daily review does not exist.

  ## Examples

      iex> get_daily_review!(123)
      %DailyReview{}

      iex> get_daily_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_daily_review_by_date(user_id, sheet_id, date), do: Repo.get_by(DailyReview, [user_id: user_id, sheet_id: sheet_id, date: date])
  def get_daily_review(user_id, sheet_id, review_id), do: Repo.get_by(DailyReview, [user_id: user_id, sheet_id: sheet_id, id: review_id])
  def get_daily_review!(user_id, sheet_id, review_id), do: Repo.get_by!(DailyReview, [user_id: user_id, sheet_id: sheet_id, id: review_id])

  @doc """
  Creates a daily_review.

  ## Examples

      iex> create_daily_review(%{field: value})
      {:ok, %DailyReview{}}

      iex> create_daily_review(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_daily_review(user_id, sheet_id, attrs \\ %{}) do
    attrs = attrs
      |> Map.put(:user_id, user_id)
      |> Map.put(:sheet_id, sheet_id)

    %DailyReview{}
    |> DailyReview.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a daily_review.

  ## Examples

      iex> update_daily_review(daily_review, %{field: new_value})
      {:ok, %DailyReview{}}

      iex> update_daily_review(daily_review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_daily_review(user_id, sheet_id, %DailyReview{} = daily_review, attrs) do
    get_daily_review!(user_id, sheet_id, daily_review.id)

    # don't allow overwriting owner or sheet
    Map.drop(attrs, [:user_id, :sheet_id])

    daily_review
    |> DailyReview.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a daily_review.

  ## Examples

      iex> delete_daily_review(daily_review)
      {:ok, %DailyReview{}}

      iex> delete_daily_review(daily_review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_daily_review!(user_id, sheet_id, %DailyReview{} = daily_review) do
    get_daily_review!(user_id, sheet_id, daily_review.id)

    Repo.delete(daily_review)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking daily_review changes.

  ## Examples

      iex> change_daily_review(daily_review)
      %Ecto.Changeset{data: %DailyReview{}}

  """
  def change_daily_review(%DailyReview{} = daily_review, attrs \\ %{}) do
    DailyReview.changeset(daily_review, attrs)
  end

  def fill_reviews() do
    with {:ok, _} = fill_daily_reviews() do
      {:ok}
    end
  end

  def fill_daily_reviews() do
    {:ok, []}
  end
end
