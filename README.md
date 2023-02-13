# HabitSheet

HabitSheet is a Web application for habit tracking. A demo instance is available at https://habitsheets.fly.dev.

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

Install dependencies:

1. Erlang
2. Elixir
3. Docker (or Postgresql)
4. Node version 12+ w/NPM

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

To deploy:

```bash
mix fly.deploy
```