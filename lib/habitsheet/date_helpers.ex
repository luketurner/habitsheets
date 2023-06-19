defmodule Habitsheet.DateHelpers do
  def short_date(date) do
    "#{date.month}/#{date.day}"
  end

  def day_of_week(date) do
    case Date.day_of_week(date) do
      1 -> "Mon"
      2 -> "Tues"
      3 -> "Wed"
      4 -> "Thurs"
      5 -> "Fri"
      6 -> "Sat"
      7 -> "Sun"
    end
  end

  def readable_timestamp(%DateTime{} = dt) do
    Calendar.strftime(
      dt,
      "%c %Z"
    )
  end

  def readable_timestamp(%NaiveDateTime{} = dt, tz) do
    dt |> DateTime.from_naive!("Etc/UTC") |> DateTime.shift_zone!(tz) |> readable_timestamp()
  end

  def readable_date(%Date{} = date) do
    # TODO
    Date.to_iso8601(date)
  end

  def today(tz \\ "Etc/UTC") do
    DateTime.to_date(DateTime.now!(tz))
  end

  def today?(%Date{} = date, tz \\ "Etc/UTC") do
    date == today(tz)
  end
end
