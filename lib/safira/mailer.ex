defmodule Safira.Mailer do

  @config   domain: Application.get_env(:safira, :mailgun_domain),
            key: Application.get_env(:safira, :mailgun_key)
  use Mailgun.Client, @config

    def send_password_email(to_email, _token) do
         send_email to: to_email,
         from: "verify@mg.seium.org",
         subject: "Welcome!",
         text: "Welcome to Safira!"
    end
end
