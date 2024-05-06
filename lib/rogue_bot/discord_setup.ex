defmodule DiscordSetup do
  alias Nostrum.Api

  def register_commands do
    command = %{
      name: "start",
      description: "Starts the game",
      options: []
    }

    Api.create_global_application_command(command)
  end
end
