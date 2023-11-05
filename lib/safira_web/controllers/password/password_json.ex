defmodule SafiraWeb.PasswordJSON do
  @moduledoc false

  def show(%{}) do
    %{
      data: %{
        attributes: %{
          info:
            "If your email address exists in our database, you will receive a password reset link at your email address."
        }
      }
    }
  end

  def ok(%{}) do
    %{data: %{attributes: %{info: "User password successfully updated."}}}
  end

  def error(%{error: error}) do
    %{errors: [%{detail: error}]}
  end
end
