defmodule Habitsheet.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habitsheet.Users` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      timezone: "Etc/UTC"
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Habitsheet.Users.register_user()

    token = extract_user_token(&Habitsheet.Users.deliver_user_confirmation_instructions(user, &1))
    {:ok, user} = Habitsheet.Users.confirm_user(token)

    user
  end

  def unconfirmed_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Habitsheet.Users.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
