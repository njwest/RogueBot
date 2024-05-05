defmodule RogueBot.GameServer do
  use GenServer

  # Starting the server
  def start_link(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  # Server callback implementation
  def init(state \\ [stage: :start]) do
    {:ok, state}
  end

  def handle_call(:get_prompt, _from, state) do
    prompt = case state.stage do
      :start -> "You see a mysterious door with a riddle: 'I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?'"
      :door_solved -> "The door opens to reveal a dark chamber, and a giant spider descends! Fight (attack) or flee?"
      _ -> "Welcome to the adventure. Type 'start' to begin or 'help' for assistance."
      end

    {:reply, prompt, state}
  end

  def handle_call({:user_input, input}, _from, state) do
    IO.inspect(state.stage)
    IO.inspect(input)
    case {state.stage, input} do
      {:start, "start"} ->
        new_state = Map.put(state, :stage, :door)

        {:reply, "You approach the door. Solve the riddle to proceed.", new_state}

      {:door, "echo"} ->
        new_state = Map.put(state, :stage, :door_solved)
        {:reply, "Correct answer! The door creaks open... to reveal a massive spider!", new_state}

      {:door_solved, "attack"} ->
        new_state = Map.put(state, :stage, :fighting)
        {:reply, "You swing your weapon at the spider. It's a hit!", new_state}

      {:door_solved, "flee"} ->
        {:reply, "You try to run away, but the spider blocks the exit!", state}

      {:fighting, _} ->
        {:reply, "With a mighty effort, you defeat the spider and find treasure behind it. You have won the game!", Map.put(state, :stage, :end)}

      _ ->
        {:reply, "I don't understand that. Try again.", state}
    end

  end

  def get_prompt(server) do
  GenServer.call(server, :get_prompt)
  end

  def send_input(server, input) do
  GenServer.call(server, {:user_input, input})
  end
end
