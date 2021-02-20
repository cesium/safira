defmodule Safira.Email do
  #use Bamboo.Phoenix, view: Safira.FeedbackView
  import Bamboo.Email

  def send_reset_email(to_email, token) do
    new_email()
    |> to(to_email)
    |> from(System.get_env("FROM_EMAIL"))
    |> subject("Reset Password Instructions")
    |> text_body("Please visit #{System.get_env("FRONTEND_URL")}/reset?token=#{token} to reset your password")
    |> Safira.Mailer.deliver_now()
  end

  def send_password_email(to_email, token, discord_association_code) do
    new_email()
    |> to(to_email)
    |> from(System.get_env("FROM_EMAIL"))
    |> subject("Finish account registration")
    |> text_body(build_email_text(token, discord_association_code))
    |> Safira.Mailer.deliver_now()
  end

  defp build_email_text(token, discord_association_code) do
    "Please visit #{System.get_env("FRONTEND_URL")}/reset?token=#{token} to finish your account registration"
  end
end
