defmodule Habitsheet.Repo do
  use Ecto.Repo,
    otp_app: :habitsheet,
    adapter: Ecto.Adapters.Postgres
end
