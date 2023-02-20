# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# application custom config values
config :habitsheet,
  require_email_verification: true,
  outgoing_email_address: "habitsheets@example.com",
  review_retention_days: 365,
  review_fill_days: 3,
  review_email_max_failure_count: 2,
  admin_email_address: "admin@example.com"

config :habitsheet,
  ecto_repos: [Habitsheet.Repo]

# Configures the endpoint
config :habitsheet, HabitsheetWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HabitsheetWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Habitsheet.PubSub,
  live_view: [signing_salt: "WOQWYalE"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :habitsheet, Habitsheet.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tailwind, version: "3.2.4", default: [
  args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
  cd: Path.expand("../assets", __DIR__)
]

config :habitsheet, Habitsheet.Reviews.Scheduler,
  overlap: false,
  run_strategy: Quantum.RunStrategy.Local,
  jobs: [
    fill_reviews: [
      schedule: "@hourly",
      task: {Habitsheet.Reviews.Scheduler, :fill_reviews_task, []}
    ]
  ]

config :habitsheet, Habitsheet.Admin.AdminEmailSender,
  overlap: false,
  run_strategy: Quantum.RunStrategy.Local,
  jobs: [
    digest: [
      schedule: "@daily",
      task: {Habitsheet.Admin.AdminEmailSender, :digest_task, []}
    ]
  ]

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
