defmodule Habitsheet.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habitsheet.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Habitsheet.Tasks.create_task()

    task
  end
end
