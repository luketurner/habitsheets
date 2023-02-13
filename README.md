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

## Development

Install dependencies:

1. Erlang
2. Elixir
3. Docker (or Postgresql)
4. Node version 12+ w/NPM

Then run:

```bash
# Run a postgres server (Or you can install one w/o using Docker)
docker run -d -p 5432:5432 --name habitsheetpg -e POSTGRES_PASSWORD=postgres postgres:15 

# install all dependencies / run migrations / etc.
mix setup

# launch devserver
mix phx.server
```

To deploy:

```bash
mix fly.deploy
```