defmodule Chatty.MockDataGenerator do
  use GenServer
  alias Chatty.Accounts
  alias Chatty.Chats
  alias Chatty.Messages

  @names ~w[Mark Alice Hugo Bob Anna]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    do_recurrent_thing(state)
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:do_work, state) do
    do_recurrent_thing(state)
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :do_work, 30_000)
  end

  defp do_recurrent_thing(_state) do
    for user <- Accounts.list_users() do
      from_name = @names |> Enum.random()

      {:ok, chat} =
        %{user_id: user.id, from_name: from_name, from_number: "+16543223456"}
        |> Chats.create_chat()

      for msg <- ~w[msg1 msg2 msg3 msg4 msg5] do
        Messages.create_message(%{chat_id: chat.id, text: msg})
      end

      IO.puts("Created mock chat #{chat.id} for user #{user.email}")
    end
  end
end
