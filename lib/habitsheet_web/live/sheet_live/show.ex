defmodule HabitsheetWeb.SheetLive.Show do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Sheets
  alias Habitsheet.Sheets.Habit

  on_mount {HabitsheetWeb.LiveInit, :load_sheet}

  @impl true
  def mount(_params, _session, socket) do
    viewport_width = socket.private.connect_params["viewport"]["width"]
    full_week_view? = breakpoint?(viewport_width, :md)
    timezone = socket.private.connect_params["browser_timezone"]
            || socket.assigns.current_user.timezone
            || "Etc/UTC"
    today = DateTime.to_date(DateTime.now!(timezone))
    date_range = if full_week_view? do
      Date.range(
        Date.beginning_of_week(today),
        Date.end_of_week(today)
      )
    else
      Date.range(today, today)
    end
    {:ok, socket
      |> assign(:date_range, date_range)
      |> assign_habits()
      |> assign_habit_entries()
      |> assign(:subtitle, socket.assigns.sheet.title || "Unnamed Sheet")
      |> assign(:viewport_width, viewport_width)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp find_habit(socket, habit_id), do: Enum.find(socket.assigns.habits, fn habit -> to_string(habit.id) == habit_id end)

  defp apply_action(socket, :edit_habit, %{"habit_id" => habit_id}) do
    habit = find_habit(socket, habit_id)
    socket
    |> assign(:page_title, "Edit habit")
    |> assign(:habit, habit)
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
    habit = find_habit(socket, habit_id)
    case Sheets.update_habit_entry_for_date_as(socket.assigns.current_user, habit, date, 1) do
      # TODO -- error handling
      {:ok, _} -> {:noreply, assign_habit_entries(socket)}
      {:error, _} -> {:noreply, assign_habit_entries(socket)}
    end

  end

  @impl true
  def handle_event("toggle_day", %{"date" => date, "habit" => habit_id}, socket) do
    habit = find_habit(socket, habit_id)
    Sheets.update_habit_entry_for_date_as(socket.assigns.current_user, habit, date, 0)
    {:noreply, assign_habit_entries(socket)}
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
      |> assign_habit_entries()}
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
      |> assign_habit_entries()}
  end

  # TODO -- this event needs to be implemented client-side before it'll do anything.
  # @impl true
  # def handle_event("viewport_resize", viewport, socket) do
  #   {:noreply, socket
  #     |> assign(:viewport_width, viewport["width"])}
  # end

  defp assign_habits(%{ assigns: %{current_user: current_user, sheet: sheet} } = socket) do
    case Sheets.list_habits_for_sheet_as(current_user, sheet) do
      {:ok, habits} -> assign(socket, :habits, habits)
      {:error, _} -> assign(socket, :habits, []) # TODO
    end
  end

  defp assign_habit_entries(%{ assigns: %{current_user: current_user, sheet: sheet, date_range: date_range, habits: habits} } = socket) do
    case Sheets.list_habit_entries_for_sheet_as(current_user, sheet, date_range) do
      {:ok, entries} -> assign(socket, :habit_entries, Sheets.habit_entry_map(habits, date_range, entries))
      {:error, _} -> assign(socket, :habit_entries, %{}) # TODO
    end
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
