defmodule HabitsheetWeb.HomeController do
  use HabitsheetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
