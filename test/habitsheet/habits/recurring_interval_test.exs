defmodule Habitsheet.Habits.RecurringIntervalTest do
  use ExUnit.Case, async: true

  alias Habitsheet.Habits.RecurringInterval, as: RI

  @every_sunday %RI{start: ~D[2023-01-01], every: 1, type: :weekly}
  @every_other_monday %RI{start: ~D[2023-01-02], every: 2, type: :weekly}

  @every_month_1st %RI{start: ~D[2023-01-01], every: 1, type: :monthly}
  @every_third_month_15th %RI{start: ~D[2023-01-15], every: 3, type: :monthly}

  test "recurs_on/2 matches for weekly intervals" do
    assert RI.recurs_on(@every_sunday, ~D[2022-12-25])
    assert RI.recurs_on(@every_sunday, ~D[2023-01-01])
    assert RI.recurs_on(@every_sunday, ~D[2023-01-08])
    assert RI.recurs_on(@every_sunday, ~D[2023-01-15])
    assert RI.recurs_on(@every_sunday, ~D[2020-02-02])
    assert RI.recurs_on(@every_sunday, ~D[2024-06-16])

    refute RI.recurs_on(@every_sunday, ~D[2023-01-02])
    refute RI.recurs_on(@every_sunday, ~D[2023-01-09])
  end

  test "recurs_on/2 matches alternating weeks when every is 2" do
    assert RI.recurs_on(@every_other_monday, ~D[2020-02-03])
    assert RI.recurs_on(@every_other_monday, ~D[2022-12-19])
    refute RI.recurs_on(@every_other_monday, ~D[2022-12-26])
    assert RI.recurs_on(@every_other_monday, ~D[2023-01-02])
    refute RI.recurs_on(@every_other_monday, ~D[2023-01-09])
    assert RI.recurs_on(@every_other_monday, ~D[2023-01-16])
    assert RI.recurs_on(@every_other_monday, ~D[2024-06-17])
  end

  test "recurs_on/2 matches the same date for monthly intervals" do
    assert RI.recurs_on(@every_month_1st, ~D[2000-11-01])
    assert RI.recurs_on(@every_month_1st, ~D[2022-11-01])
    assert RI.recurs_on(@every_month_1st, ~D[2022-12-01])
    assert RI.recurs_on(@every_month_1st, ~D[2023-01-01])
    assert RI.recurs_on(@every_month_1st, ~D[2023-02-01])
    assert RI.recurs_on(@every_month_1st, ~D[2023-03-01])
    assert RI.recurs_on(@every_month_1st, ~D[2030-03-01])

    refute RI.recurs_on(@every_month_1st, ~D[2023-01-02])
  end

  test "recurs_on/2 matches every 3rd month when every is 3" do
    assert RI.recurs_on(@every_third_month_15th, ~D[2000-10-15])
    assert RI.recurs_on(@every_third_month_15th, ~D[2022-10-15])
    refute RI.recurs_on(@every_third_month_15th, ~D[2022-11-15])
    refute RI.recurs_on(@every_third_month_15th, ~D[2022-12-15])
    assert RI.recurs_on(@every_third_month_15th, ~D[2023-01-15])
    refute RI.recurs_on(@every_third_month_15th, ~D[2023-02-15])
    refute RI.recurs_on(@every_third_month_15th, ~D[2023-03-15])
    assert RI.recurs_on(@every_third_month_15th, ~D[2023-04-15])
    refute RI.recurs_on(@every_third_month_15th, ~D[2023-05-15])
    refute RI.recurs_on(@every_third_month_15th, ~D[2023-06-15])
    assert RI.recurs_on(@every_third_month_15th, ~D[2023-07-15])
    assert RI.recurs_on(@every_third_month_15th, ~D[2030-07-15])
  end
end
