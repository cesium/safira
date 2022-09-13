defmodule Safira.ReferralFactory do
  defmacro __using__(_opts) do
    quote do
      def referral_factory do
        %Safira.Contest.Referral{
          available: true,
          badge: build(:badge)
        }
      end
    end
  end
end
