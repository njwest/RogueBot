defmodule RogueBot.Repo do
  use Ecto.Repo,
    otp_app: :rogue_bot,
    adapter: Ecto.Adapters.Postgres
end
