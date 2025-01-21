defmodule Safira.Standalone do
  use Nebulex.Cache,
    otp_app: :safira,
    adapter: NebulexRedisAdapter
end
