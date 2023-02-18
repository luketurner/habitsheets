defmodule HabitsheetWeb.DailyReviewLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Reviews

  on_mount HabitsheetWeb.OwnedSheetLiveAuth

  @impl true
  def mount(%{ "id" => _sheet_id, "date" => date_param }, _session, socket) do
    date = Date.from_iso8601!(date_param)
    user_id = socket.assigns.current_user.id
    sheet_id = socket.assigns.sheet.id
    with {:ok, review} = Reviews.get_or_create_daily_review_by_date(user_id, sheet_id, date) do
      habits = Reviews.get_habits_for_daily_review(review)
      {:ok,
      socket
      |> assign(:sheet_id, sheet_id)
      |> assign(:date, date)
      |> assign(:review, review)
      |> assign(:habits, habits)}
    end
  end

end
