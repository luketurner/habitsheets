defmodule HabitsheetWeb.SheetLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Habit

  on_mount HabitsheetWeb.OwnedSheetLiveAuth

  @impl true
  def mount(%{ "id" => id }, _session, socket) do
    viewport_width = socket.private.connect_params["viewport"]["width"]
    full_week_view? = breakpoint?(viewport_width, :md)
    date_range = if full_week_view? do
      Sheets.get_week_range(Date.utc_today())
    else
      today = Date.utc_today()
      Date.range(today, today)
    end
    {:ok, socket
      |> assign(:id, id)
      |> assign(:habits, list_habits(socket, id))
      |> assign(:date_range, date_range)
      |> assign(:habit_entries, all_habit_entries(socket, id, date_range))
      |> assign(:subtitle, socket.assigns.sheet.title || "Unnamed Sheet")
      |> assign(:viewport_width, viewport_width)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_habit, %{"habit_id" => habit_id}) do
    socket
    |> assign(:page_title, "Edit habit")
    |> assign(:habit, Sheets.get_habit!(socket.assigns.current_user.id, habit_id))
  end

  defp apply_action(socket, :new_habit, _params) do
    socket
    |> assign(:page_title, "New habit")
    |> assign(:habit, %Habit{})
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Sheet")
    |> assign(:habit, nil)
  end

  defp apply_action(socket, :share, _params) do
    socket
    |> assign(:page_title, "Share Sheet")
    |> assign(:habit, nil)
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Edit Sheet")
    |> assign(:habit, nil)
  end

  @impl true
  def handle_event("toggle_day", %{"value" => _value, "date" => date, "habit" => habit_id}, socket) do
    Sheets.update_habit_entry_for_date!(socket.assigns.current_user.id, habit_id, date, 1)
    {:noreply, assign(socket, :habit_entries, all_habit_entries(socket, socket.assigns.id, socket.assigns.date_range))}
  end

  @impl true
  def handle_event("toggle_day", %{"date" => date, "habit" => habit_id}, socket) do
    Sheets.update_habit_entry_for_date!(socket.assigns.current_user.id, habit_id, date, 0)
    {:noreply, assign(socket, :habit_entries, all_habit_entries(socket, socket.assigns.id, socket.assigns.date_range))}
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
      |> assign(:habit_entries, all_habit_entries(socket, socket.assigns.id, new_range))
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
      |> assign(:habit_entries, all_habit_entries(socket, socket.assigns.id, new_range))
    }
  end

  # TODO -- this event needs to be implemented client-side before it'll do anything.
  # @impl true
  # def handle_event("viewport_resize", viewport, socket) do
  #   {:noreply, socket
  #     |> assign(:viewport_width, viewport["width"])}
  # end

  defp list_habits(socket, sheet_id) do
    Sheets.list_habits_for_sheet!(socket.assigns.current_user.id, sheet_id)
  end

  defp all_habit_entries(socket, sheet_id, days) do
    Map.new(list_habits(socket, sheet_id), fn habit -> {
      habit.id,
      entries_for_habit(socket, habit.id, days)
    } end)
  end

  defp entries_for_habit(socket, habit_id, days) do
    Sheets.get_habit_entry_value_map(socket.assigns.current_user.id, habit_id, days)
  end

  # defp get_habit_entry_for_date(habit_entries, habit_id, date) do
  #   habit_entries
  #   |> Map.get(habit_id, Map.new())
  #   |> Map.get(date, nil)
  # end

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
