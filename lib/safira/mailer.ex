defmodule Safira.Mailer do

  @config   domain: Application.get_env(:safira, :mailgun_domain),
            key: Application.get_env(:safira, :mailgun_key)
  use Mailgun.Client, @config

    def send_password_email do
      IO.inspect @config

         send_email to: "test_mail",
         from: "teste@seium.org",
         subject: "Welcome!",
         text: "Welcome to Safira!"
    end
end
