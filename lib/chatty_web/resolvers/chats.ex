defmodule ChattyWeb.Resolvers.Chats do
  alias Chatty.Chats
  alias Chatty.Chats

  def list_chats(_parent, _args, %{context: %{current_user: user}}) do
    chats =
      Chats.list_chats_for_user_with_last_message(user)
      |> build_chat_dtos()

    {:ok, chats}
  end

  def list_chats(_parent, _args, _resolution) do
    {:error, "You are not logged in"}
  end

  def list_chat_messages(_parent, %{chat_id: chat_id}, %{context: %{current_user: user}}) do
    with chat when not is_nil(chat) <- Chats.get_chat(chat_id),
         true <- chat.user_id == user.id do
      messages = Chats.list_chat_messages(chat_id)

      {:ok, messages}
    else
      _ -> {:error, "Chat not found"}
    end
  end

  def list_chat_messages(_parent, _args, _resolution) do
    {:error, "You are not logged in"}
  end

  def send_message(_parent, %{chat_id: chat_id, text: text}, %{context: %{current_user: user}}) do
    with chat when not is_nil(chat) <- Chats.get_chat(chat_id),
         true <- chat.user_id == user.id do
      Chats.create_message(%{chat_id: chat_id, text: text, direction: :outbound})
    else
      _ -> {:error, "Chat not found"}
    end
  end

  def send_message(_parent, _args, _resolution) do
    {:error, "You are not logged in"}
  end

  def new_chat_message_config(%{chat_id: chat_id}, %{context: %{current_user: user}}) do
    with chat when not is_nil(chat) <- Chats.get_chat(chat_id),
         true <- chat.user_id == user.id do
      {:ok, topic: chat.id}
    else
      _ -> {:error, "Chat not found"}
    end
  end

  def new_chat_message_config(_args, _resolution) do
    {:error, "You are not logged in"}
  end

  def chats_list_changed_config(_args, %{context: %{current_user: user}}) when is_struct(user) do
    {:ok, topic: user.id}
  end

  def chats_list_changed_config(_args, _resolution) do
    {:error, "You are not logged in"}
  end

  defp build_chat_dtos(chats) do
    for chat <- chats do
      last_message =
        case chat.messages do
          [m | _] -> m
          _ -> nil
        end

      Map.from_struct(chat)
      |> Map.put(:last_message, last_message)
      |> Map.put(:contact, %{name: chat.from_name, phone_number: chat.from_number})
    end
  end
end
