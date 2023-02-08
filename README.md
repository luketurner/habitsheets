# Habitsheet

## Tables

Note: `(R)` indicates field is required (non-null constraint).

```mermaid
erDiagram
  Sheet {
    uuid id PK "(R)"
    string title "(R)"
  }

  Habit {
    uuid id PK "(R)"
    uuid sheet_id FK "(R)"
    string name "(R)"
    enum type "(R) task | count | measure"
    int goal_high
    int goal_low
  }

  HabitRelation {
    uuid first FK
    uuid second FK
    enum type "chain"
  }

  HabitStatistic {
    uuid habit_id FK "PK: habit_id + range + start"
    enum value_type "(R) task | count | measure"
    enum range "(R) day | week | month | year"
    date start "(R) inclusive"
    date end "(R) exclusive"
    int value_count "num. values recorded in the range" 
    int value_sum "sum of recorded values"
    int value_mean "mean of recorded values"
  }

  Sheet ||--|{ Habit: has_many
  Habit }|..|{ Habit: habit_relation
  Habit ||--|{ HabitStatistic: has_many
```

## Development

Install dependencies:

1. Erlang
2. Elixir
3. Docker (or Postgresql)

Then run:

```bash
# Run a postgres server (Or you can install one w/o using Docker)
docker run -d -p 5432:5432 --name habitsheetpg -e POSTGRES_PASSWORD=postgres postgres:15 

mix deps.get
mix ecto.setup
mix phx.server
```

## Original content

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
