defmodule DiscordBot do
  use Nostrum.Consumer

  alias RogueBot.GameServer
  alias Nostrum.Api

  def handle_event(%Nostrum.Struct.Message{content: content, channel_id: channel_id} = message, state) do
    # Filtering out messages from bots, including itself
    if not Map.get(message.author, :bot, false) do
      process_command(content, channel_id)
    end
    {:noreply, state}
  end

  def handle_event(%Nostrum.Struct.Interaction{data: %{"name" => "start"}, channel_id: channel_id}, state) do
    IO.inspect("HIIIII")
    # {:ok, _} = GameServer.ensure_started()
    prompt = GameServer.get_prompt(GameServer)
    interaction_response(channel_id, prompt)
    {:noreply, state}
  end

  def handle_event(event, state) do
    IO.inspect("Unhandled Event")

    IO.inspect(event)
    {:noreply, state}  # Ignore other types of events
  end

  defp interaction_response(channel_id, message) do
    Nostrum.Api.create_interaction_response(channel_id, message)
  end

  defp process_command("start", channel_id) do
    # This is where you handle starting the game or resetting it
    GameServer.start_link()  # Ensure this handles restarts or checks if it's already running
    prompt = GameServer.get_prompt(GameServer)

    send_message_to_channel(channel_id, prompt)
  end

  defp process_command(input, channel_id) do
    # Send the input to the GameServer and get the response
    response = GameServer.send_input(GameServer, input)
    send_message_to_channel(channel_id, response)
  end

  def send_message_to_channel(channel_id, message) do
    Api.create_message(channel_id, message)
    |> handle_api_response()
  end

  defp handle_api_response({:ok, response}) do
    {:ok, response}
  end

  defp handle_api_response({:error, reason}) do
    {:error, reason}
  end
end
