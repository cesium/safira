defmodule Safira.Email do

  def send_reset_email(to_email, token) do
    # new_email()
    # |> to(to_email)
    # |> from(System.get_env("FROM_EMAIL"))
    # |> subject("Reset Password Instructions")
    # |> text_body("Please visit #{System.get_env("FRONTEND_URL")}/reset?token=#{token} to reset your password")
  end

  # def send_password_email(to_email, token) do

  #   send_email to: to_email,
  #   from: "us@example.com",
  #   subject: "Welcome!",
  #   text: "Welcome to HelloPhoenix!"

    # new_email()
    # |> to(to_email)
    # |> from(System.get_env("FROM_EMAIL"))
    # |> subject("Finish account registration")
    # |> text_body("Please visit #{System.get_env("FRONTEND_URL")}/reset?token=#{token} to finish your account registration")
  #end
end
