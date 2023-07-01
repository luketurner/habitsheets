defmodule HabitsheetWeb.Components do
  use HabitsheetWeb, :component

  alias Ecto.Changeset
  alias Habitsheet.Habits.HabitEntry
  alias Habitsheet.Habits.AdditionalData

  embed_templates("components/*.html")

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_minus_circle_outline(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_bars_three_outline(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_pencil_square_outline(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_ellipsis_horizontal_circle_outline(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_check_circle_solid(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_play_solid(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_pause_solid(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_arrow_path_solid(assigns)

  attr(:rest, :global, default: %{class: "w-5 h-5"})
  def icon_pencil_square_mini(assigns)

  attr(:rest, :global, default: %{class: "w-5 h-5"})
  def icon_academic_cap_mini(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_bell_snooze_outline(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_clock_outline(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_exclamation_circle_outline(assigns)

  attr(:rest, :global, default: %{class: "w-6 h-6"})
  def icon_fire_outline(assigns)

  attr(:rest, :global, default: %{class: "text-xl font-bold pb-4"})
  slot(:inner_block)
  def page_title(assigns)

  attr(:habit, Habitsheet.Sheets.Habit)
  attr(:rest, :global, default: %{class: ""})
  slot(:inner_block)
  def habit_label(assigns)

  attr(:entry, Habitsheet.Sheets.HabitEntry)
  attr(:readonly, :boolean, default: false)
  attr(:click, :any, default: nil)
  attr(:rest, :global, default: %{class: "swap"})
  # these must be specified to create new entries in case entry is nil
  attr(:date, Date, default: nil)
  attr(:habit_id, :any, default: nil)
  def habit_entry_status(assigns)

  attr(:cols, :list)
  attr(:rows, :list)
  slot(:col_label)
  slot(:row_label)
  slot(:cell)
  slot(:next_btn)
  slot(:prev_btn)
  attr(:rest, :global)
  def flex_table(assigns)

  attr(:conn_or_socket, :any, required: true)
  attr(:manpage, :string)
  attr(:theme, :string, required: true)
  slot(:inner_block, required: true)
  slot(:nav_menu, required: true)
  slot(:nav_title, required: true)
  slot(:nav_subtitle)
  slot(:footer, required: true)
  def layout(assigns)

  slot(:inner_block)
  attr(:rest, :global, default: %{class: "breadcrumbs text-sm font-semibold mx-3 mt-2 mb-4"})
  def breadcrumbs(assign)

  slot(:inner_block)
  slot(:drawer)
  attr(:id, :any, required: true)
  attr(:checked, :boolean)
  attr(:close_href, :string)
  def drawer(assigns)

  slot(:inner_block)
  slot(:title)
  slot(:subtitle)
  slot(:menu)
  def navbar_drawer(assigns)

  attr(:manpage, :string)
  slot(:inner_block)
  def manpage_drawer(assigns)

  attr(:to, :string)
  def manpage_link(assigns)

  attr(:habit, Habitsheet.Habits.Habit, required: true)
  attr(:entry, Habitsheet.Habits.HabitEntry)
  attr(:date, Date, required: true)
  attr(:on_additional_data_change, :string, required: true)
  attr(:on_toggle, :string, required: true)

  def habit_entry_row(%{entry: entry, habit: habit, date: date} = assigns) do
    assigns = assign(assigns, :changeset, changeset_for_entry(entry, habit, date))

    ~H"""
    <div
      class={"bg-neutral text-neutral-content hover:bg-neutral-focus w-100 min-h-16 my-2 mx-4 rounded-lg shadow-xl flex flex-col flex-nowrap justify-center select-none pointer-events-auto cursor-pointer"}
      phx-value-id={@habit.id}
      {if Enum.empty?(@habit.additional_data_spec || []), do: [phx_click: @on_toggle], else: []}>
      <div class="flex flex-row flex-nowrap items-center mx-4">
        <%= if @entry do %>
          <UI.icon_check_circle_solid class="w-8 h-8" />
        <% else %>
          <UI.icon_minus_circle_outline class="w-8 h-8" />
        <% end %>
        <div class="flex-grow py-2 px-4 text-lg">
          <%= @habit.name %>
        </div>
      </div>
      <div class="flex flex-row flex-wrap">
        <%= if @habit.expiration && @habit.expiration > 1 do %>
          <div class="badge badge-primary m-1" title={"#{@habit.expiration} day expiration"}>
            <.icon_bell_snooze_outline />
            <%= @habit.expiration %> days
          </div>
        <% end %>
        <%= for recurrence <- @habit.recurrence do %>
          <div class="badge badge-accent m-1" title={Habitsheet.Habits.RecurringInterval.to_display_sentence(recurrence)}>
            <.icon_clock_outline />
            <%= Habitsheet.Habits.RecurringInterval.to_display_string(recurrence) %>
          </div>
        <% end %>
      </div>
      <div>
        <UI.additional_data_editor
          changeset={@changeset}
          habit={@habit}
          on_change={@on_additional_data_change} />
      </div>

      <%= unless Habitsheet.Notes.empty?(@habit.notes) do %>
        <div class="flex flex-row">
          <.icon_pencil_square_outline />
          <div class="prose text-neutral-content m-1" style="--bc: --text-neutral-content">
            <%= raw Habitsheet.Notes.render(@habit.notes) %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  attr(:habit, Habitsheet.Habits.Habit, required: true)
  attr(:changeset, Ecto.Changeset, required: true)
  attr(:on_change, :string, required: true)

  def additional_data_editor(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@changeset}
      id={"habit_#{@habit.id}"}
      phx-change={@on_change}>

      <%= hidden_input f, :id %>
      <%= hidden_input f, :habit_id %>
      <%= hidden_input f, :date %>
      <.inputs_for :let={data} field={f[:additional_data]}>
        <%= hidden_input data, :id %>
        <%= hidden_input data, :data_type %>
        <%= case Changeset.get_field(data.source, :data_type) do %>

        <% :count -> %>
          <div class="form-control mb-2 mx-2 w-100 max-w-xs">
            <%= label data, :value, Enum.find(@habit.additional_data_spec, nil, fn v -> v.id == Changeset.get_field(data.source, :id) end).label, class: "label label-text text-inherit" %>
            <div class="input-group">
              <button class="btn" onclick={"document.getElementById('#{input_id(data, :value)}').stepDown(); document.getElementById('#{input_id(data, :value)}').dispatchEvent(new Event('input', {bubbles: true})); event.stopPropagation(); event.preventDefault();"}>-</button>
              <%= number_input data, :value, class: "input input-bordered text-base-content", step: 1, min: 0 %>
              <button class="btn" onclick={"document.getElementById('#{input_id(data, :value)}').stepUp(); document.getElementById('#{input_id(data, :value)}').dispatchEvent(new Event('input', {bubbles: true})); event.stopPropagation(); event.preventDefault();"}>+</button>
            </div>
          </div>

        <% :measurement -> %>
          <div class="form-control mb-2 mx-2 w-100 max-w-xs">
            <%= label data, :value, Enum.find(@habit.additional_data_spec, nil, fn v -> v.id == Changeset.get_field(data.source, :id) end).label, class: "label label-text text-inherit" %>
            <%= number_input data, :value, class: "input input-bordered text-base-content", step: "0.001" %>
          </div>

        <% :duration -> %>
          <div class="form-control mb-2 mx-2 w-100 max-w-xs">
            <%= label data, :value, Enum.find(@habit.additional_data_spec, nil, fn v -> v.id == Changeset.get_field(data.source, :id) end).label, class: "label label-text text-inherit" %>
            <!-- TODO: Some kind of duration input -->
            <%= text_input data, :value, class: "input input-bordered text-base-content" %>
          </div>

        <% :text -> %>
          <div class="form-control mb-2 mx-2 w-100 max-w-xs">
            <%= label data, :value, Enum.find(@habit.additional_data_spec, nil, fn v -> v.id == Changeset.get_field(data.source, :id) end).label, class: "label label-text text-inherit" %>
            <%= text_input data, :value, class: "input input-bordered text-base-content" %>
          </div>

        <% end %>
      </.inputs_for>
    </.form>
    """
  end

  defp changeset_for_entry(entry, habit, date) do
    if entry do
      HabitEntry.changeset(entry, %{
        additional_data: build_additional_data(entry.additional_data, habit)
      })
    else
      HabitEntry.create_changeset(%HabitEntry{}, %{
        habit_id: habit.id,
        date: date,
        additional_data: build_additional_data([], habit)
      })
    end
  end

  defp build_additional_data(current_data, habit) do
    current_data
    |> AdditionalData.zip_spec(habit.additional_data_spec)
    |> Enum.map(fn {data, _spec} -> Map.take(data, AdditionalData.__schema__(:fields)) end)
  end

  attr(:task, Habitsheet.Tasks.Task, required: true)
  attr(:date, Date, required: true)
  attr(:on_toggle, :string, required: true)

  def task_entry_row(assigns) do
    ~H"""
    <div
      class={"bg-neutral text-neutral-content hover:bg-neutral-focus w-100 min-h-16 my-2 mx-4 rounded-lg shadow-xl flex flex-col flex-nowrap justify-center select-none pointer-events-auto cursor-pointer"}
      phx-value-id={@task.id}
      phx-click={@on_toggle}>
      <div class="flex flex-row flex-nowrap items-center mx-4">
        <%= if @task.completed_at do %>
          <UI.icon_check_circle_solid class="w-8 h-8" />
        <% else %>
          <UI.icon_minus_circle_outline class="w-8 h-8" />
        <% end %>
        <div class="flex-grow py-2 px-4 text-lg">
          <%= @task.name %>
        </div>
      </div>
      <div class="flex flex-row flex-wrap">
        <%= if @task.important do %>
          <div class="badge badge-primary m-1">
            <.icon_exclamation_circle_outline />
            important
          </div>
        <% end %>
        <%= if @task.urgent do %>
          <div class="badge badge-accent m-1">
            <.icon_fire_outline />
            urgent
          </div>
        <% end %>
      </div>
      <div class="prose text-neutral-content m-1" style="--bc: --text-neutral-content">
        <%= raw Habitsheet.Notes.render(@task.notes) %>
      </div>
    </div>
    """
  end
end
