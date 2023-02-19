defmodule Habitsheet.Reviews.ReviewEmailSender do
  import Swoosh.Email

  alias Habitsheet.Repo

  alias Habitsheet.Mailer
  alias Habitsheet.Reviews
  alias Habitsheet.Reviews.DailyReview

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"HabitSheets", Application.get_env(:habitsheet, :outgoing_email_address)})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp subject(review), do: "[#{review.sheet.title}] Daily Review: #{review.date}"

  defp body(review), do: "Placeholder review for #{review.date}"

  def send_email_for_daily_review(review, email, trigger) do
    review = Repo.preload review, :sheet

    case deliver(email, subject(review), body(review)) do
      {:ok, _email} -> {:ok, handle_success(review, email, trigger)}
      {:error, error} -> {:error, handle_failure(review, email, trigger, error)}
    end
  end

  defp handle_success(review, email, trigger) do
    Repo.update(DailyReview.changeset(review, %{
      email_status: :sent,
      email_attempt_count: review.email_attempt_count + 1
    }))
    Reviews.create_daily_review_email(%{
      daily_review_id: review.id,
      email: email,
      attempt: review.email_attempt_count + 1,
      status: :success,
      trigger: trigger
    })
  end

  defp handle_failure(review, email, trigger, error) do
    Repo.update(DailyReview.changeset(review, %{
      email_status: :failed,
      email_attempt_count: review.email_attempt_count + 1,
      email_failure_count: review.email_failure_count + 1
    }))
    Reviews.create_daily_review_email(%{
      daily_review_id: review.id,
      email: email,
      attempt: review.email_attempt_count + 1,
      status: :failure,
      trigger: trigger,
      error_text: error
    })
  end
end
