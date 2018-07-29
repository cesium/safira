defmodule Mix.Tasks.Gen.QrCodes do
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest

  @arg_types ["attendees", "referrals"]
  @url "https://intra.seium.org/"

  def run(args) do
    cond do
      length(args) != 1 ->
        Mix.shell.info "Needs to receive attendees or referrals."
      true ->
        args |> List.first |> create
    end
  end

  defp create(arg) when arg in @arg_types do
    Mix.Task.run "app.start"

    if arg == "attendees" do
      Enum.each Accounts.list_attendees, fn(attendee) ->
        QrCodeSvg.generate(
          "#{@url}attendees/#{attendee.id}", 
          "attendee_#{attendee.id}.svg"
        )
      end
    else
      Enum.each Contest.list_referrals, fn(referral) ->
        QrCodeSvg.generate(
          "#{@url}referrals/#{referral.id}", 
          "referral_#{referral.id}.svg"
        )
      end
    end
  end
end
