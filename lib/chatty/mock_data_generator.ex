defmodule Chatty.MockDataGenerator do
  use GenServer
  alias Chatty.Accounts
  alias Chatty.Chats
  alias Chatty.Messages
  alias Chatty.Mocks.Names
  alias Chatty.Mocks.Numbers
  alias Chatty.Mocks.Quotes

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
    Process.send_after(self(), :do_work, 15_000)
  end

  defp do_recurrent_thing(_state) do
    for user <- Accounts.list_users() do
      generate_mock_data_for_user(user)
    end

    :ok
  end

  defp generate_mock_data_for_user(user) do
    chats = Chats.list_chats_for_user(user)
    chats_count = Enum.count(chats)

    generate_new_chat? = chats_count == 0 or :rand.uniform(100) < 20

    if generate_new_chat? do
      generate_mock_chat_for_user(user, chats)
    else
      generate_mock_mesage_for_chats(chats)
    end

    :ok
  end

  defp generate_mock_chat_for_user(user, existing_chats) do
    from_name =
      existing_chats
      |> Enum.map(& &1.from_name)
      |> Names.random_name()

    from_number =
      existing_chats
      |> Enum.map(& &1.from_number)
      |> Numbers.random_number()

    {:ok, chat} =
      Chats.create_chat(%{
        user_id: user.id,
        from_name: from_name,
        from_number: from_number
      })

    for _ <- 1..:rand.uniform(5) do
      Messages.create_message(%{
        chat_id: chat.id,
        text: Quotes.random_quote()
      })
    end

    {:ok, chat}
  end

  defp generate_mock_mesage_for_chats(chats) do
    chat_ids =
      chats
      |> Enum.sort_by(& &1.inserted_at, :asc)
      |> Enum.map(& &1.id)

    chat_ids_for_sorting =
      chat_ids
      |> Enum.reduce([], fn {id, index}, acc -> acc ++ List.duplicate(id, index + 1) end)

    random_chat_id =
      chat_ids_for_sorting
      |> Enum.random()

    Messages.create_message(%{
      chat_id: random_chat_id,
      text: Quotes.random_quote()
    })
  end
end
