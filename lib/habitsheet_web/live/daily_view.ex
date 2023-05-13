defmodule HabitsheetWeb.Live.DailyView do
  use HabitsheetWeb, :live_view

  alias Habitsheet.Reviews
  alias Habitsheet.Reviews.DailyReview
  alias Ecto.Changeset

  alias Habitsheet.Habits
  alias Habitsheet.Habits.HabitEntry
  alias Habitsheet.Habits.AdditionalData

  @impl true
  def mount(%{"date" => date_param} = _params, _session, socket) do
    {:ok,
     socket
     |> assign(:date_param, date_param)
     |> assign_habits()
     |> assign_entries()
     |> assign_review()}
  end

  @impl true
  def handle_event("toggle_entry", %{"id" => habit_id}, socket) do
    habit = get_habit_from_socket(socket, habit_id)

    entry = socket.assigns.entry_map[String.to_integer(habit_id)]

    additional_data = if(entry, do: :delete, else: [])

    with {:ok, _entry} <-
           Habits.update_habit_entry_for_date_as(
             socket.assigns.current_user,
             habit,
             socket.assigns.date,
             additional_data
           ) do
      {:noreply,
       socket
       |> assign_entries()}
    end
  end

  @impl true
  def handle_event(
        "update_entry",
        %{
          "habit_entry" => %{"habit_id" => habit_id_param, "date" => date_param} = entry_params
        },
        socket
      ) do
    # Massage params
    habit = get_habit_from_socket(socket, habit_id_param)
    date = Date.from_iso8601!(date_param)
    entry_params = Map.put_new(entry_params, "additional_data", [])

    # Validate changes
    changeset = HabitEntry.create_changeset(%HabitEntry{}, entry_params)
    entry = Changeset.apply_action!(changeset, :validate)

    # Create or update the entry
    case Habits.update_habit_entry_for_date_as(
           socket.assigns.current_user,
           habit,
           date,
           entry.additional_data
         ) do
      {:ok, _entry} ->
        {:noreply, socket |> assign_entries()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def assign_habits(socket) do
    with {:ok, habits} <-
           Habits.list_habits_for_user_as(
             socket.assigns.current_user,
             socket.assigns.current_user
           ) do
      socket
      |> assign(:habits, habits)
    end
  end

  def assign_entries(%{assigns: %{current_user: current_user, date: date}} = socket) do
    with {:ok, entries} <-
           Habits.list_entries_for_user_as(current_user, current_user, date) do
      socket
      |> assign(:entries, entries)
      |> assign(
        :entry_map,
        Habits.entry_map(entries)
      )
    end
  end

  defp assign_review(%{assigns: %{current_user: current_user, date: date}} = socket) do
    changeset =
      Reviews.review_upsert_changeset(%DailyReview{}, %{
        date: date,
        user_id: current_user.id
      })

    # TODO I don't want to actually create a review until the user does some modification
    with {:ok, review} <- Reviews.upsert_review_for_date_as(current_user, changeset) do
      socket |> assign(:review, review)
    else
      _ -> socket
    end
  end

  defp get_habit_from_socket(socket, habit_id) when is_integer(habit_id) do
    Enum.find(socket.assigns.habits, &(&1.id == habit_id))
  end

  defp get_habit_from_socket(socket, habit_id) when is_binary(habit_id) do
    get_habit_from_socket(socket, String.to_integer(habit_id))
  end

  defp get_entry_from_socket(socket, entry_id) when is_integer(entry_id) do
    Enum.find(socket.assigns.entries, &(&1.id == entry_id))
  end

  defp get_entry_from_socket(socket, entry_id) when is_binary(entry_id) do
    get_entry_from_socket(socket, String.to_integer(entry_id))
  end

  defp date_param_add(date, days) do
    date |> Date.add(days) |> Date.to_iso8601()
  end
end
