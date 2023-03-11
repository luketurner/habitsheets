defmodule HabitsheetWeb.LiveHelpers do
  import Phoenix.Component

  alias Phoenix.LiveView.JS

  alias Habitsheet.Users
  alias Habitsheet.Habits.Habit

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.habit_statistic_index_path(@socket, :index)}>
        <.live_component
          module={HabitsheetWeb.HabitStatisticLive.FormComponent}
          id={@habit_statistic.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.habit_statistic_index_path(@socket, :index)}
          habit_statistic: @habit_statistic
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="modal modal-open" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="modal-box"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <.link patch={@return_to} id="close" class="absolute right-2 top-2 btn btn-sm btn-circle" phx-click={hide_modal()}>✕</.link>
        <% else %>
          <.link href="#" id="close" class="absolute right-2 top-2 btn btn-sm btn-circle" phx-click={hide_modal()}>✕</.link>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  def assign_user_for_session(socket, %{"user_token" => user_token} = _session) do
    assign(socket, :current_user, Users.get_user_by_session_token(user_token))
  end

  def assign_browser_params(socket) do
    # TODO -- is there a built-in way to detect this?
    loaded? = socket.private.connect_params["loaded"] == true

    socket
    |> assign(:browser_params_assigned?, loaded?)
    |> assign_timezone()
    |> assign_viewport()
  end

  def assign_timezone(socket) do
    timezone =
      socket.private.connect_params["browser_timezone"] ||
        socket.assigns.current_user.timezone ||
        "Etc/UTC"

    assign(socket, :timezone, timezone)
  end

  def assign_viewport(socket) do
    width = socket.private.connect_params["viewport"]["width"]
    height = socket.private.connect_params["viewport"]["height"]
    assign(socket, :viewport, %{width: width, height: height})
  end

  def assign_date(socket, "today") do
    assign_date(socket, DateTime.to_date(DateTime.now!(socket.assigns.timezone)))
  end

  def assign_date(socket, date) when is_binary(date) do
    assign_date(socket, Date.from_iso8601!(date))
  end

  def assign_date(socket, %Date{} = date) do
    assign(socket, :date, date)
  end

  def short_date(date) do
    "#{date.month}/#{date.day}"
  end

  def day_of_week(date) do
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

  def readable_timestamp(%DateTime{} = dt) do
    Calendar.strftime(
      dt,
      "%c %Z"
    )
  end

  def readable_timestamp(%NaiveDateTime{} = dt, tz) do
    dt |> DateTime.from_naive!("Etc/UTC") |> DateTime.shift_zone!(tz) |> readable_timestamp()
  end

  def breakpoint?(%{assigns: %{viewport: %{width: viewport_width}}} = _socket, breakpoint) do
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

  def classes_for_habit(%Habit{} = habit) do
    # Note -- when editing this function, also update the safelist in tailwind.config.js
    if habit.display_color == :base do
      # Base color is a special case because the class names don't exactly match
      "bg-base-300 text-base-content"
    else
      color =
        case habit.display_color do
          :primary -> "primary"
          :secondary -> "secondary"
          :accent -> "accent"
          :neutral -> "neutral"
          :info -> "info"
          :success -> "success"
          :warning -> "warning"
          :error -> "error"
          _ -> "primary"
        end

      "bg-#{color} text-#{color}-content"
    end
  end

  # TODO -- this event needs to be implemented client-side before it'll do anything.
  # @impl true
  # def handle_event("viewport_resize", viewport, socket) do
  #   {:noreply, socket
  #     |> assign(:viewport_width, viewport["width"])}
  # end
end
