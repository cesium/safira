defmodule Safira.Mailer do
  use Swoosh.Mailer, otp_app: :safira

  def get_sender_name do
    Application.get_env(:safira, :from_email_name)
  end

  def get_sender_address do
    Application.get_env(:safira, :from_email_address)
  end
end
