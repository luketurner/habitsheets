defmodule HabitsheetWeb.SharedSheetLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheets

  @impl true
  def mount(%{ "id" => share_id }, _session, socket) do
    viewport_width = socket.private.connect_params["viewport"]["width"]
    timezone = get_in(socket.private, [:connect_params, "browser_timezone"])
            || get_in(socket.assigns, [:current_user, :timezone])
            || "Etc/UTC"
    full_week_view? = breakpoint?(viewport_width, :md)
    today = DateTime.to_date(DateTime.now!(timezone))
    date_range = if full_week_view? do
      Sheets.get_week_range(today)
    else
      Date.range(today, today)
    end
    sheet = Sheets.get_sheet_by_share_id!(share_id)
    habits = list_habits(sheet)
    {:ok, socket
      |> assign(:sheet, sheet)
      |> assign(:habits, habits)
      |> assign(:date_range, date_range)
      |> assign(:habit_entries, all_habit_entries(sheet, habits, date_range))
      |> assign(:subtitle, sheet.title || "Unnamed Sheet")
      |> assign(:viewport_width, viewport_width)
      |> assign(:timezone, timezone)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Sheet")
    |> assign(:habit, nil)
  end

  @impl true
  def handle_event("prev_week", _params, socket) do
    old_range = socket.assigns.date_range
    new_range = Date.range(
      Date.add(old_range.first, -Enum.count(old_range)),
      Date.add(old_range.first, -1)
    )
    {:noreply, socket
      |> assign(:date_range, new_range)
      |> assign(:habit_entries, all_habit_entries(socket.assigns.sheet, socket.assigns.habits, new_range))
    }
  end

  @impl true
  def handle_event("next_week", _params, socket) do
    old_range = socket.assigns.date_range
    new_range = Date.range(
      Date.add(old_range.last, 1),
      Date.add(old_range.last, Enum.count(old_range))
    )
    {:noreply, socket
      |> assign(:date_range, new_range)
      |> assign(:habit_entries, all_habit_entries(socket.assigns.sheet, socket.assigns.habits, new_range))
    }
  end

  defp list_habits(sheet) do
    Sheets.list_habits_for_shared_sheet(sheet.share_id)
  end

  defp all_habit_entries(sheet, habits, days) do
    Map.new(habits, fn habit -> {
      habit.id,
      entries_for_habit(sheet, habit.id, days)
    } end)
  end

  defp entries_for_habit(sheet, habit_id, days) do
    Sheets.get_shared_habit_entry_value_map(sheet.share_id, habit_id, days)
  end

  defp short_date(date) do
    "#{date.month}/#{date.day}"
  end

  defp day_of_week(date) do
    case Date.day_of_week(date) do
      1 -> "M"
      2 -> "T"
      3 -> "W"
      4 -> "T"
      5 -> "F"
      6 -> "S"
      7 -> "S"
    end
  end

  # TODO -- abstract this stuff into a helper

  defp breakpoint?(viewport_width, breakpoint) do
    points = %{
      sm: 640,
      md: 768,
      lg: 1024,
      xl: 1280,
      twoxl: 1536
    }
    width = points[breakpoint]
    !is_nil(viewport_width) && width <= viewport_width
  end

end
