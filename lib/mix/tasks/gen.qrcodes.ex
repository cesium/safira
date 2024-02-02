defmodule Mix.Tasks.Gen.QrCodes do
  @moduledoc """
  Task to generate the QR codes for the attendees

  Expects FRONTEND_URL variable to be set.
  Example: https://seium.org
  """
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest

  @arg_types ["attendees", "referrals"]

  def run(args) do
    if args |> List.first() |> (&Enum.member?(@arg_types, &1)).() |> Kernel.not() do
      Mix.shell().info("Needs to receive attendees or referrals.")
    else
      args |> List.first() |> create
    end
  end

  defp create(arg) when arg in @arg_types do
    Mix.Task.run("app.start")

    url = System.get_env("FRONTEND_URL")

    if arg == "attendees" do
      Enum.each(Accounts.list_attendees(), fn attendee ->
        qr =
          "#{url}/attendees/#{attendee.id}"
          |> QRCodeEx.encode()
          |> QRCodeEx.png(width: 460)

        File.write("qrs/#{attendee.id}.png", qr, [:binary])
      end)
    else
      Enum.each(Contest.list_referrals(), fn referral ->
        QrCodeSvg.generate(
          "#{url}referrals/#{referral.id}",
          "referral_#{referral.id}.svg"
        )
      end)
    end
  end
end
