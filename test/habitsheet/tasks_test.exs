defmodule Habitsheet.TasksTest do
  use Habitsheet.DataCase

  alias Habitsheet.Tasks

  describe "tasks" do
    alias Habitsheet.Tasks.Task

    import Habitsheet.TasksFixtures

    @invalid_attrs %{name: nil}

  end

  describe "agendas" do
    alias Habitsheet.Tasks.Agenda

    import Habitsheet.TasksFixtures

    @invalid_attrs %{date: nil}
  end
end
