defmodule Habitsheet.Reviews.Scheduler do
  use Quantum, otp_app: :habitsheet

  alias Habitsheet.Reviews

  def fill_reviews_task() do
    num_days = Application.get_env(:habitsheet, :review_fill_days)
    # TODO -- does this need timezone awareness?
    today = Date.utc_today()
    date_range = Date.range(Date.add(today, -num_days), today)

    Reviews.fill_daily_reviews(date_range)
    Reviews.send_emails_for_daily_reviews_with_pending_attempts()
  end
end
