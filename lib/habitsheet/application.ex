defmodule Habitsheet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Habitsheet.Repo,
      # Start the Telemetry supervisor
      HabitsheetWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Habitsheet.PubSub},
      # Start the Endpoint (http/https)
      HabitsheetWeb.Endpoint,
      # Start background tasks

      # TODO -- temporarily disable review sending
      # Habitsheet.Reviews.Scheduler,
      Habitsheet.Admin.AdminEmailSender
      # {Tz.WatchPeriodically, [interval_in_days: 7]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Habitsheet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HabitsheetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
