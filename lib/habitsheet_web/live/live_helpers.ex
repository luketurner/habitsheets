defmodule HabitsheetWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

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
          <%= live_patch "✕",
            to: @return_to,
            id: "close",
            class: "absolute right-2 top-2 btn btn-sm btn-circle",
            phx_click: hide_modal()
          %>
        <% else %>
          <a id="close" href="#" class="absolute right-2 top-2 btn btn-sm btn-circle" phx-click={hide_modal()}>✕</a>
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
end
