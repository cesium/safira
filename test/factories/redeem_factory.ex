defmodule Safira.RedeemFactory do
  defmacro __using__(_opts) do
    quote do
      def redeem_factory do
        %Safira.Contest.Redeem{}
      end
    end
  end
end
