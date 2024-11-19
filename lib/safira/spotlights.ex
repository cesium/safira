defmodule Safira.Spotlights do
    use Safira.Context

    alias Safira.Constants

    def change_duration_spotlight(time) do
        Constants.set("duration_spotlights", time)
    end

    def get_spotlights_duration do
        case Constants.get("duration_spotlights") do
            {:ok , duration} ->
                duration

            {:error, _ } ->
                change_duration_spotlight(0)
                0
        end
    end
end
