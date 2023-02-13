# HabitSheet

HabitSheet is a Web application for habit tracking. A demo instance is available at https://habitsheets.fly.dev. Be aware that HabitSheets is under active development and the demo instance data may be wiped at any time.

HabitSheets is open-source (MIT Licensed) and it's easy to deploy your own instance on [Fly.io](https://fly.io/) with just a few commands. See [Deployment](#deployment) section for details.

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

## Local Development

Install dependencies for local development:

1. Git
2. [Elixir](https://elixir-lang.org/install.html)
3. Docker (or Postgresql)
4. Node version 12+ w/NPM

Clone the repository:

```bash
git clone https://github.com/luketurner/habitsheets.git
```

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

When running locally, Phoenix LiveDashboard is available at http://localhost:4000/dashboard.

## Deployment

The HabitSheets demo instance is currently deployed on Fly.io.

If you want to set up your own deployment on Fly, you need the following dependencies:

1. Git
2. [Elixir](https://elixir-lang.org/install.html) (for `mix` commands)
3. [flyctl](https://fly.io/docs/hands-on/install-flyctl/).

clone this repo and use `fly launch` to generate a new app name in the `fly.toml`:

```bash
git clone https://github.com/luketurner/habitsheets.git
fly launch --copy-config --remote-only
```

To deploy:

```bash
mix fly.deploy
```

Then you can open the app:

```bash
fly open
```

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
```