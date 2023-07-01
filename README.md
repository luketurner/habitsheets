# HabitSheets

HabitSheets is a Web application for habit tracking. A demo instance is available at https://habitsheets.fly.dev. Be aware that HabitSheets is under active development and the demo instance data may be wiped at any time.

HabitSheets is open-source (MIT Licensed) and it's easy to deploy your own instance on [Fly.io](https://fly.io/) with just a few commands. See [Development](#development) section for details.

The in-app help documentation can also be [read on Github](priv/manpage), although cross-page links won't work outside of the app.

## Getting Started Guide (WIP)

To make best use of HabitSheets (or any habit-tracking software), your first task, _before even opening the app_, is to set aside a few minutes a day for reflection. Without a habit of daily reflection, the full benefit of habit tracking can't be realized.

To get started building the habit of daily reflection, I recommend using **habit chaining**:

Find a habit you already have -- something you do daily, ideally in the evening -- that you can use as a reminder to reflect on the day. Examples:

- Just finished dinner
- Before brushing your teeth
- After walking your dog

Create a **link** in your mind between the existing habit and the new habit (reflecting on the day).  

When reflecting at first, just let your mind think about the day in whatever way is easiest for you. Sometimes, tracking can feel stressful and get in the way of reflection. I especially recommend this if you've struggled with habit tracking in the past.

Once you get used to reflecting daily -- which likely won't take long, if you _chained the habit_ and _made it easy_ -- you might start to feel like it would be easier to reflect if you had a checklist. This is a good time to start using an app.

## Effectively building habits

To build a habit, setting intent is not enough. You need a trigger, internal or external, to bring up a thought at the appropriate time. There are two kinds of triggers you can use:

- **Existing habits** (referred to as _habit chaining_)
- **Reminders/Notifications**

Using existing habits is the more natural-feeling method in most cases, and the one I recommend using when possible.

Reminders from external systems like HabitSheets should only be used for triggering habits that (a) only recur infrequently or (b) must happen at a specific time.

One other essential concern:

- **Keep it easy**

Have you ever experienced a kind of inertia when starting a new habit? Not that you don't remember to do it, but somehow even though you _know_ you should... you just don't? That's a sign -- it means the habit is too difficult.

#### Habit chaining

When using an existing habit as a trigger for a new habit, there are two things to consider:

- **Good trigger** - The existing habit should happen consistently at the right time and place.
- **Good coupling** - The existing habit should somehow "bring to mind" the new habit.

When selecting the existing habit, you're looking for a good trigger. Since many habits operate below conscious awareness, one technique to find good triggers is to write down all your habits throughout the day.

Once you've selected the habit, form a mental linkage -- a good coupling -- with the new desired habit. Any two habits can be coupled together by use of the **link** mneumonic technique (see The Memory Book).


#### References / Further Reading

- Atomic Habits
- Getting Things Done
- The Memory Book

## Usage notes

(WIP - to be incorporated into in-app documentation.)

In HabitSheets, a Habit is any kind of behavior you want to bring to conscious awareness through tracking and reflection. A habit could be specific (e.g. "meditate for at least 15 minutes before bed") or it could be a general point for reflection (e.g. "Was I generous today?")

### Habit Data

Habits can have additional data fields associated with them beyond a yes/no status:

- **Count** fields record positive integer like: number of squats, number of times you said thank you, etc.
- **Measurement** fields record continuous quantities from some measurement or calculation, like: weight, number of calories, distance walked, etc.
- **Duration** fields record durations, like: duration of run, duration of meditation, etc.
- **Text** fields record arbitrary textual data, like: notes about weather, mood, etc.

Would also like to add:

- **Sets** fields record zero-or-more "sets" of exercises, e.g. 3x10 squats or 1, 2, 3, 2, 1 bench presses


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
- [Quantum](https://github.com/quantum-elixir/quantum-core)
- [Swoosh](https://github.com/swoosh/swoosh)
- [gen_smtp](https://github.com/gen-smtp/gen_smtp) 
- [Tz](https://github.com/mathieuprog/tz) and [TzExtra](https://github.com/mathieuprog/tz_extra)

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
   - The project includes mix tasks to run development database with [Podman](https://podman.io/).

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
  OUTGOING_EMAIL_ADDRESS="habitsheets-noreply@example.com"
```

If you want to use HabitSheets without setting up a mailer, you can disable the requirement for email verification by setting this value in `config/config.exs`:

```elixir
config :habitsheet,
  require_email_verification: false # <--
```

### Admin email digests

HabitSheets can send a daily email with a high-level summary of the database content (currently, just table counts). No user information is included.

To receive emails, configure an `ADMIN_EMAIL_ADDRESS` environment variable:

```bash
fly secrets set ADMIN_EMAIL_ADDRESS="me@example.com"
```

If `ADMIN_EMAIL_ADDRESS` is not set, the admin email feature is disabled.

### Other notes

To connect to the app and inspect state in production:

```bash
# Open an IEx connection
fly ssh console -C "/app/bin/habitsheet remote"
```

For example, once connected with `iex`, we can use Ecto to inspect state in the production DB:

```bash
# List all users
Habitsheet.Repo.all(Habitsheet.Users.User)

# Delete all habits
Habitsheet.Repo.delete_all(Habitsheet.Habits.Habit)
```