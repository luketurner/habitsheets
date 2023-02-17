defmodule Habitsheet.Reviews.Scheduler do
  use Quantum, otp_app: :habitsheet

  alias Habitsheet.Reviews

  def fill_reviews_task() do
    Reviews.fill_reviews()
  end
end
