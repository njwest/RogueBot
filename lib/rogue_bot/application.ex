defmodule RogueBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RogueBotWeb.Telemetry,
      RogueBot.Repo,
      {DNSCluster, query: Application.get_env(:rogue_bot, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RogueBot.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RogueBot.Finch},
      # Start a worker by calling: RogueBot.Worker.start_link(arg)
      # {RogueBot.Worker, arg},
      # Start to serve requests, typically the last entry
      RogueBotWeb.Endpoint,
      ExampleConsumer,
      {RogueBot.GameServer, %{stage: :start}}  # Start the game server
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RogueBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RogueBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
