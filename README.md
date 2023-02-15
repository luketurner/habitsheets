# HabitSheets

HabitSheets is a Web application for habit tracking. A demo instance is available at https://habitsheets.fly.dev. Be aware that HabitSheets is under active development and the demo instance data may be wiped at any time.

HabitSheets is open-source (MIT Licensed) and it's easy to deploy your own instance on [Fly.io](https://fly.io/) with just a few commands. See [Development](#development) section for details.

## Tech notes

An experiment with the so-called PETAL (Phoenix, Elixir, TailwindCSS, AlpineJS, LiveView) stack.

More explicitly, the following 3rd party libraries/technologies are used:

- [Postgresql](https://www.postgresql.org/)
- [Elixir](https://elixir-lang.org/)
- [Phoenix](https://www.phoenixframework.org/) (incl. [LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html))
- [AlpineJS](https://alpinejs.dev/) (not yet, but when I need purely client-side interactivity, I'll use it then)
- [TailwindCSS](https://tailwindcss.com/)
- [Heroicons](https://heroicons.com/)
- [daisyUI](https://daisyui.com/)
- [Fly.io](https://fly.io/)

## Development

This section is for folks that want to either:

1. Contribute to HabitSheets
2. Run a self-hosted HabitSheets deployment

### Dependencies

Required dependencies:

1. [Git](https://git-scm.com/)
2. [Elixir](https://elixir-lang.org/install.html)

For local development (running `mix phx.server` to test HabitSheets locally), you'll also need:

1. [Node](https://nodejs.org/en/) v12+ w/NPM
2. A [Postgresql](https://www.postgresql.org/) server running at `localhost:5432` with username `postgres` and password `postgres`
   - The project includes mix tasks to run development database with [Docker](https://www.docker.com/) (or equivalent, e.g. [Podman](https://podman.io/)).

For deployment, you don't need Node/Postgres, but you _do_ still need Git/Elixir, as well as:

1. [flyctl](https://fly.io/docs/hands-on/install-flyctl/)

Finally, you need to clone this repository:

```bash
git clone https://github.com/luketurner/habitsheets.git
```

### Local development steps

For local development, run:

```bash
# Run a Postgres server with Docker
mix pg.dev.setup
mix pg.dev.start

# install all dependencies / run migrations / etc.
mix setup

# launch devserver
mix phx.server
```

When running locally, there are some routes available for easier testing:

- http://localhost:4000/dev/mailbox -- development email mailbox
- http://localhost:4000/dashboard -- Phoenix LiveDashboard

### Deployment steps and self-hosting

The HabitSheets demo instance is currently deployed on [Fly.io](https://fly.io/).

If you want to self-host HabitSheets on Fly, use `fly launch` to generate a new app name in the `fly.toml`:

```bash
fly launch --copy-config --remote-only
```

Once you've launched, you can open the app:

```bash
fly open
```

Deploy new versions of the site with:

```bash
mix fly.deploy
```

HabitSheets is configured to send emails over SMTP with StartTLS and user-password auth. For this to work you'll need to set environment variables:

```bash
fly secrets set \
  MAILER_SMTP_RELAY="smtp.example.com" \
  MAILER_SMTP_PORT="587" \
  MAILER_SMTP_USERNAME="foobar" \
  MAILER_SMTP_PASSWORD="password" \
  MAILER_OUTGOING_EMAIL="habitsheets-noreply@example.com"
```

If you want to use HabitSheets without setting up a mailer, you can disable the requirement for email verification by setting this value in `config/config.exs`:

```elixir
config :habitsheet,
  require_email_verification: false # <--
```

### Other notes

To connect to the app and inspect state in production:

```bash
# Open an IEx connection
fly ssh console -C "/app/bin/habitsheet remote"
```

For example, once connected with `iex`, we can use Ecto to inspect state in the production DB:

```bash
# Count of sheets
Habitsheet.Repo.aggregate(Habitsheet.Sheets.Sheet, :count)

# List all users
Habitsheet.Repo.all(Ecto.Query.from u in Habitsheet.Users.User)

# Delete all habits
Habitsheet.Repo.delete_all(Habitsheet.Sheets.Habit)
```