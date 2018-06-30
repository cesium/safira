defmodule Safira.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :safira,
  module: Safira.Guardian,
  error_handler: Safira.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
