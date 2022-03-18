defmodule Chatty.Mocks do
  require Logger
  alias Chatty.Accounts
  alias Chatty.Chats
  alias Chatty.Chats
  alias Chatty.Mocks.Names
  alias Chatty.Mocks.Numbers
  alias Chatty.Mocks.Quotes
  alias Chatty.Repo

  def clean_all_data do
    Repo.transaction(fn ->
      Repo.delete_all(Chatty.Chats.Message)
      Repo.delete_all(Chatty.Chats.Chat)
    end)
  end

  def maybe_send_mock_reply(chat_id) do
    if :rand.uniform(100) < 75 do
      Task.start(fn ->
        :timer.sleep(1500)

        {:ok, _messsage} =
          Chats.create_message(%{
            chat_id: chat_id,
            text: Quotes.random_quote(),
            direction: :inbound
          })

        Logger.info("Sent mock reply to chat #{chat_id}")
      end)
    end

    :ok
  end

  def generate_more_mock_data() do
    for user <- Accounts.list_users() do
      generate_mock_data_for_user(user)
    end

    :ok
  end

  defp generate_mock_data_for_user(user) do
    chats = Chats.list_chats_for_user(user)
    chats_count = Enum.count(chats)

    generate_new_chat? = chats_count == 0 or :rand.uniform(100) <= rem(abs(13 - chats_count), 13)

    if generate_new_chat? do
      generate_mock_chat_for_user(user, chats)
    else
      generate_mock_mesage_for_chats(user, chats)
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

    for _ <- 0..:rand.uniform(5) do
      {:ok, _messsage} =
        Chats.create_message(%{
          chat_id: chat.id,
          text: Quotes.random_quote(),
          direction: :inbound
        })
    end

    Logger.info("Created mock chat for #{user.email}")

    {:ok, chat}
  end

  defp generate_mock_mesage_for_chats(user, chats) do
    if :rand.uniform(100) < 55 do
      do_generate_mock_mesage_for_chats(user, chats)
    else
      Logger.info("Skipping generating mock message for #{user.email}")
      {:ok, nil}
    end
  end

  defp do_generate_mock_mesage_for_chats(user, chats) do
    chat_ids =
      chats
      |> Enum.sort_by(& &1.inserted_at, :asc)
      |> Enum.map(& &1.id)

    chat_ids_for_sorting =
      chat_ids
      |> Enum.with_index()
      |> Enum.reduce([], fn {id, index}, acc -> acc ++ List.duplicate(id, index + 1) end)

    random_chat_id =
      chat_ids_for_sorting
      |> Enum.random()

    {:ok, _messsage} =
      Chats.create_message(%{
        chat_id: random_chat_id,
        text: Quotes.random_quote(),
        direction: :inbound
      })

    Logger.info("Created mock message for #{user.email} (chat #{random_chat_id})")
  end
end
