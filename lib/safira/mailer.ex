defmodule Safira.Mailer do

  @config   domain: Application.get_env(:safira, :mailgun_domain),
            key: Application.get_env(:safira, :mailgun_key)
  use Mailgun.Client, @config

  def send_reset_email(to_email, token) do
    send_email to: to_email,
         from: System.get_env("FROM_EMAIL"),
         subject: "Reset Password Instructions",
         text: "Please visit #{System.get_env("FRONTEND_URL")}/reset?token=#{token} to reset your password"
  end

  def send_password_email(to_email, token) do
    IO.puts System.get_env("FROM_EMAIL")
    send_email to: to_email,
        from: System.get_env("FROM_EMAIL"),
        subject: "Finish account registration",
        text: "Please visit #{System.get_env("FRONTEND_URL")}/reset?token=#{token} to finish your account registration"
  end
end
