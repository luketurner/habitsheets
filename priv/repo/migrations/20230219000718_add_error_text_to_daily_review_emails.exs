defmodule Habitsheet.Repo.Migrations.AddErrorTextToDailyReviewEmails do
  use Ecto.Migration

  def change do
    alter table(:daily_review_emails) do
      add :error_text, :text
    end
  end
end
